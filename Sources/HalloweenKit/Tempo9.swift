// Copyright (c) 2026 Jiejing Zhang.
//
// Finding the tempo9 server the page needs, or starting one.  halloween
// does no inference itself: tempo9 runs the vision encoder and the model,
// and this only checks that one is answering with vision on.

import Foundation

public enum Tempo9 {
    /// What `halloween` starts when nothing is listening: Qwen3.5-9B with its
    /// matching Core ML vision encoder, both fetched on first use.
    public static let defaultModel = "unsloth/Qwen3.5-9B-GGUF:Q4_K_S"
    public static let defaultServer = URL(string: "http://127.0.0.1:11435")!

    public enum Status: Equatable {
        case down
        case ready(model: String)
        case noVision(model: String)
        /// Vision on, but no POST /v1/vision/frame: a tempo9 from before the
        /// route existed, which the page's gate cannot work without.
        case tooOld(model: String)
    }

    /// GET /v1/models, then POST /api/show for its capabilities.
    public static func probe(_ base: URL) async -> Status {
        var get = URLRequest(url: base.appendingPathComponent("v1/models"))
        get.timeoutInterval = 3
        guard let (data, resp) = try? await URLSession.shared.data(for: get),
              (resp as? HTTPURLResponse)?.statusCode == 200,
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let first = (obj["data"] as? [[String: Any]])?.first,
              let model = first["id"] as? String
        else { return .down }
        var show = URLRequest(url: base.appendingPathComponent("api/show"))
        show.httpMethod = "POST"
        show.timeoutInterval = 10
        show.setValue("application/json", forHTTPHeaderField: "Content-Type")
        show.httpBody = try? JSONSerialization.data(withJSONObject: ["model": model])
        guard let (sd, _) = try? await URLSession.shared.data(for: show),
              let so = try? JSONSerialization.jsonObject(with: sd) as? [String: Any]
        else { return .noVision(model: model) }
        let caps = so["capabilities"] as? [String] ?? []
        guard caps.contains("vision") else { return .noVision(model: model) }
        // An empty frame request: 400 ("image required") where the route
        // exists, 404 where it does not.
        var frame = URLRequest(url: base.appendingPathComponent("v1/vision/frame"))
        frame.httpMethod = "POST"
        frame.timeoutInterval = 10
        frame.setValue("application/json", forHTTPHeaderField: "Content-Type")
        frame.httpBody = Data("{}".utf8)
        if let (_, fr) = try? await URLSession.shared.data(for: frame),
           (fr as? HTTPURLResponse)?.statusCode == 404 { return .tooOld(model: model) }
        return .ready(model: model)
    }

    /// tempo9 on PATH, or where Homebrew puts it when PATH is thin (a
    /// launcher, a cron job).
    public static func executable(path: String? = ProcessInfo.processInfo.environment["PATH"]) -> URL? {
        let dirs = (path ?? "").split(separator: ":").map(String.init) + ["/opt/homebrew/bin", "/usr/local/bin"]
        for d in dirs {
            let u = URL(fileURLWithPath: d).appendingPathComponent("tempo9")
            if FileManager.default.isExecutableFile(atPath: u.path) { return u }
        }
        return nil
    }

    /// Starts tempo9 with the default model and its vision encoder.  Its
    /// output goes straight to this terminal, download progress included.
    public static func launch(_ exe: URL, port: Int) throws -> Process {
        let p = Process()
        p.executableURL = exe
        p.arguments = ["--hf", defaultModel, "--tower", "auto", "--port", String(port)]
        try p.run()
        return p
    }
}
