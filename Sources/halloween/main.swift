// Copyright (c) 2026 Jiejing Zhang.
//
// halloween: point your Mac's camera at the door, and whoever walks in gets
// a skeleton -- a cute one for children and pets, a scary one for adults.
// Everything runs on the Mac: tempo9 does the looking, this serves the page.
//
//   halloween                 start tempo9 if needed, open the page
//   halloween --no-open       same, without opening the browser
//   halloween --port 1031     where the page is served (Oct 31)
//   halloween --server URL    a tempo9 already running elsewhere on this Mac

import Foundation
import HalloweenKit

let version = "0.1.0"

func say(_ s: String) { FileHandle.standardError.write(Data((s + "\n").utf8)) }
func fail(_ s: String) -> Never { say("halloween: " + s); exit(1) }

var port: UInt16 = 1031
var server = Tempo9.defaultServer
var openBrowser = true
var args = CommandLine.arguments.dropFirst()
while let a = args.popFirst() {
    switch a {
    case "--port":
        guard let v = args.popFirst(), let p = UInt16(v), p > 0 else { fail("--port needs a number") }
        port = p
    case "--server":
        guard let v = args.popFirst(), let u = URL(string: v), u.host != nil else { fail("--server needs a URL") }
        server = u
    case "--no-open":
        openBrowser = false
    case "--version":
        print("halloween \(version)"); exit(0)
    case "-h", "--help":
        say("usage: halloween [--port 1031] [--server http://127.0.0.1:11435] [--no-open]")
        exit(0)
    default:
        fail("unknown option \(a) (try --help)")
    }
}

// Globals the signal handler and the startup task share; declared before
// either runs.
nonisolated(unsafe) var child: Process?
nonisolated(unsafe) var keep: Server?
nonisolated(unsafe) var signalSources: [DispatchSourceSignal] = []

// Ctrl-C stops tempo9 too, when this started it.
for sig in [SIGINT, SIGTERM] {
    signal(sig, SIG_IGN)
    let src = DispatchSource.makeSignalSource(signal: sig, queue: .main)
    src.setEventHandler {
        if let c = child, c.isRunning { c.terminate(); c.waitUntilExit() }
        say("\nhalloween: stopped")
        exit(0)
    }
    src.resume()
    signalSources.append(src)
}
Task {
    var status = await Tempo9.probe(server)
    if status == .down {
        // Start one only on this Mac; a server named elsewhere is the user's.
        guard ["127.0.0.1", "localhost"].contains(server.host ?? "") else {
            fail("nothing answers at \(server.absoluteString). Start tempo9 there with --tower auto.")
        }
        guard let exe = Tempo9.executable() else {
            fail("tempo9 is not installed. Install it first:\n\n    brew install thinkspread/tap/tempo9\n")
        }
        say("halloween: starting tempo9 with \(Tempo9.defaultModel) and its vision encoder")
        say("halloween: the first run downloads about 6.4 GB; later runs start in seconds\n")
        do { child = try Tempo9.launch(exe, port: server.port ?? 11435) } catch {
            fail("could not start \(exe.path): \(error)")
        }
        while status == .down {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if let c = child, !c.isRunning {
                fail("tempo9 exited (status \(c.terminationStatus)) before it was ready")
            }
            status = await Tempo9.probe(server)
        }
    }
    switch status {
    case .noVision(let m):
        fail("tempo9 is serving \(m) without a vision encoder. Restart it with --tower auto.")
    case .tooOld:
        fail("this tempo9 is too old for halloween (it has no /v1/vision/frame). Update it:\n\n    brew upgrade tempo9\n")
    case .ready(let m):
        let s = Server(port: port, tempo9: server)
        do { try s.start() } catch { fail("\(error) (another halloween running? try --port)") }
        keep = s
        let url = "http://127.0.0.1:\(port)/"
        say("\n🎃 Halloween mode: \(url)   (tempo9: \(m))")
        say("   Press Start and allow the camera. Ctrl-C here to stop.")
        if openBrowser {
            let o = Process()
            o.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            o.arguments = [url]
            try? o.run()
        }
    case .down:
        fail("tempo9 did not come up")
    }
    // Stop with tempo9 if it stops underneath us.
    while true {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        if let c = child, !c.isRunning { fail("tempo9 exited (status \(c.terminationStatus))") }
    }
}
dispatchMain()
