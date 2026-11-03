// Copyright (c) 2026 Jiejing Zhang.
//
// A loopback HTTP server with four routes: the page, and three calls handed
// on to tempo9 unchanged.  The page could not call tempo9 directly: it is
// served from another port, which makes it another origin, and tempo9 sends
// no CORS headers on purpose (no other site the browser has open may read
// local answers).  Serving the page here and forwarding keeps that intact.

import Foundation
import Network

public final class Server: @unchecked Sendable {
    /// Calls the page makes, and the only ones forwarded.
    public static let forwarded: Set<String> = [
        "GET /v1/models", "POST /v1/chat/completions", "POST /v1/vision/frame",
    ]

    let port: UInt16
    let tempo9: URL
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "halloween.server")
    private let session: URLSession = {
        let c = URLSessionConfiguration.ephemeral
        c.timeoutIntervalForRequest = 180
        return URLSession(configuration: c)
    }()

    public init(port: UInt16, tempo9: URL) {
        self.port = port
        self.tempo9 = tempo9
    }

    public enum StartError: Error, CustomStringConvertible {
        case bind(UInt16, String)
        public var description: String {
            switch self {
            case .bind(let p, let why): return "cannot listen on 127.0.0.1:\(p): \(why)"
            }
        }
    }

    /// Returns once the port is bound; a port in use is an error here, not
    /// a server that silently answers nothing.
    public func start() throws {
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        params.requiredLocalEndpoint = NWEndpoint.hostPort(
            host: .ipv4(.loopback), port: NWEndpoint.Port(rawValue: port)!)
        let l = try NWListener(using: params)
        l.newConnectionHandler = { [weak self] conn in self?.serve(conn) }
        let sem = DispatchSemaphore(value: 0)
        var failure: String?
        l.stateUpdateHandler = { state in
            switch state {
            case .ready: sem.signal()
            case .failed(let e), .waiting(let e): failure = "\(e)"; sem.signal()
            default: break
            }
        }
        l.start(queue: queue)
        if sem.wait(timeout: .now() + 10) == .timedOut { failure = "timed out" }
        if let failure { l.cancel(); throw StartError.bind(port, failure) }
        listener = l
    }

    // MARK: - connections

    private func serve(_ conn: NWConnection) {
        conn.start(queue: queue)
        read(conn, Data())
    }

    private func read(_ conn: NWConnection, _ buffer: Data) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 1 << 20) { [weak self] data, _, done, err in
            guard let self, err == nil else { conn.cancel(); return }
            var buf = buffer
            if let data { buf.append(data) }
            if let req = Request(complete: buf) {
                Task { await self.respond(req, conn) }
            } else if done || buf.count > 32 << 20 {
                conn.cancel()
            } else {
                self.read(conn, buf)
            }
        }
    }

    private func respond(_ req: Request, _ conn: NWConnection) async {
        let reply: Data
        if req.method == "GET", req.path == "/" {
            reply = Self.pageResponse()
        } else if Self.forwarded.contains("\(req.method) \(req.path)") {
            reply = await forward(req)
        } else {
            reply = Self.response(404, "application/json", Data(#"{"error":{"message":"not found"}}"#.utf8))
        }
        conn.send(content: reply, completion: .contentProcessed { _ in conn.cancel() })
    }

    private func forward(_ req: Request) async -> Data {
        var r = URLRequest(url: tempo9.appendingPathComponent(String(req.path.dropFirst())))
        r.httpMethod = req.method
        if req.method == "POST" {
            r.httpBody = req.body
            r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        do {
            let (body, resp) = try await session.data(for: r)
            let http = resp as? HTTPURLResponse
            return Self.response(http?.statusCode ?? 502,
                                 http?.value(forHTTPHeaderField: "Content-Type") ?? "application/json", body)
        } catch {
            let msg = "tempo9 at \(tempo9.absoluteString) did not answer: \(error.localizedDescription)"
            let body = (try? JSONSerialization.data(withJSONObject: ["error": ["message": msg]])) ?? Data()
            return Self.response(502, "application/json", body)
        }
    }

    // MARK: - responses

    public static func pageResponse() -> Data {
        response(200, "text/html; charset=utf-8", Data(Page.html.utf8), extra: [
            "Content-Security-Policy: \(Page.contentSecurityPolicy)",
            "X-Content-Type-Options: nosniff",
            "Referrer-Policy: no-referrer",
        ])
    }

    static func response(_ status: Int, _ type: String, _ body: Data, extra: [String] = []) -> Data {
        let reason = [200: "OK", 400: "Bad Request", 404: "Not Found", 502: "Bad Gateway"][status] ?? "Status"
        var head = "HTTP/1.1 \(status) \(reason)\r\nContent-Type: \(type)\r\n"
        head += "Content-Length: \(body.count)\r\nCache-Control: no-store\r\nConnection: close\r\n"
        for h in extra { head += h + "\r\n" }
        return Data((head + "\r\n").utf8) + body
    }
}

/// One HTTP/1.1 request, once all of it has arrived.
struct Request {
    let method: String
    let path: String
    let body: Data

    init?(complete buf: Data) {
        guard let end = buf.range(of: Data("\r\n\r\n".utf8)) else { return nil }
        let head = String(decoding: buf[..<end.lowerBound], as: UTF8.self)
        let lines = head.components(separatedBy: "\r\n")
        let parts = (lines.first ?? "").split(separator: " ")
        guard parts.count >= 2 else { return nil }
        var length = 0
        for line in lines.dropFirst() {
            let kv = line.split(separator: ":", maxSplits: 1)
            if kv.count == 2, kv[0].lowercased() == "content-length" {
                length = Int(kv[1].trimmingCharacters(in: .whitespaces)) ?? 0
            }
        }
        let bodyStart = end.upperBound
        guard buf.count - bodyStart >= length else { return nil }
        method = String(parts[0])
        path = String(parts[1].split(separator: "?", maxSplits: 1).first ?? "")
        body = Data(buf[bodyStart..<bodyStart + length])
    }
}
