// Copyright (c) 2026 Jiejing Zhang.

import XCTest
@testable import HalloweenKit

final class PageTests: XCTestCase {
    /// "Everything runs on this Mac" is the page's claim; the policy and the
    /// page are held to it.
    func testPageLoadsNothingFromTheNetwork() {
        let csp = Page.contentSecurityPolicy
        XCTAssertTrue(csp.contains("default-src 'none'"))
        XCTAssertTrue(csp.contains("connect-src 'self'"))
        XCTAssertFalse(csp.contains("*") || csp.contains("http"))
        for needle in ["http://", "https://", "<link", "@import", "src=\"//"] {
            XCTAssertFalse(Page.html.contains(needle), "page references \(needle)")
        }
    }

    /// Every call the page makes is one the server forwards, and nothing
    /// else is forwarded.
    func testPageCallsOnlyForwardedRoutes() throws {
        let re = try NSRegularExpression(pattern: #"fetch\("(/[^"]*)""#)
        let html = Page.html
        var called = Set<String>()
        for m in re.matches(in: html, range: NSRange(html.startIndex..., in: html)) {
            called.insert(String(html[Range(m.range(at: 1), in: html)!]))
        }
        XCTAssertEqual(called, ["/v1/models", "/v1/chat/completions", "/v1/vision/frame"])
        XCTAssertEqual(Set(Server.forwarded.map { String($0.split(separator: " ")[1]) }), called)
    }

    /// Children and pets get the cute skeleton, adults the scary one, and
    /// both skeletons are in the page.
    func testRulesPairAgeWithSkeleton() {
        let html = Page.html
        XCTAssertTrue(html.contains(#"{ when: "a child", say: "Hi there! Happy Halloween, little one.", kind: "cute" }"#))
        XCTAssertTrue(html.contains(#"{ when: "an adult", say: "Boo! Got you. Happy Halloween!", kind: "scary" }"#))
        XCTAssertTrue(html.contains(#"{ when: "小孩", say: "嗨！万圣节快乐，小朋友。", kind: "cute" }"#))
        XCTAssertTrue(html.contains(#"{ when: "大人", say: "吓到了吧！万圣节快乐！", kind: "scary" }"#))
        XCTAssertTrue(html.contains(#"id="booCute""#) && html.contains(#"id="booScary""#))
    }

    /// Both languages carry the same keys, so neither shows a hole.
    func testEveryStringHasBothLanguages() throws {
        let html = Page.html
        func keys(_ lang: String) throws -> Set<String> {
            let start = html.range(of: "  \(lang): { title:")!.lowerBound
            let end = html.range(of: "voice:", range: start..<html.endIndex)!.upperBound
            let block = String(html[start..<end])
            // A key follows "{", "," or a line break; "Camera: " inside a
            // value does not.
            let re = try NSRegularExpression(pattern: #"(?:[{,]|\n)\s*(\w+): ""#)
            return Set(re.matches(in: block, range: NSRange(block.startIndex..., in: block)).map {
                String(block[Range($0.range(at: 1), in: block)!]) })
        }
        let en = try keys("en"), zh = try keys("zh")
        XCTAssertGreaterThan(en.count, 8)
        XCTAssertEqual(en, zh)
    }

    func testPageResponseIsLockedDown() {
        let r = String(decoding: Server.pageResponse(), as: UTF8.self)
        XCTAssertTrue(r.hasPrefix("HTTP/1.1 200 OK\r\n"))
        XCTAssertTrue(r.contains("Content-Security-Policy: \(Page.contentSecurityPolicy)\r\n"))
        XCTAssertTrue(r.contains("Cache-Control: no-store\r\n"))
    }

    func testRequestWaitsForTheWholeBody() {
        let head = "POST /v1/vision/frame?x=1 HTTP/1.1\r\nContent-Length: 4\r\n\r\n"
        XCTAssertNil(Request(complete: Data((head + "ab").utf8)))
        let r = Request(complete: Data((head + "abcd").utf8))
        XCTAssertEqual(r?.method, "POST")
        XCTAssertEqual(r?.path, "/v1/vision/frame")
        XCTAssertEqual(r?.body, Data("abcd".utf8))
    }
}
