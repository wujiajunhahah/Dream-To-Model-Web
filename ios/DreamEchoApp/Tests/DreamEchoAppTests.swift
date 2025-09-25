import XCTest
@testable import DreamEchoApp

final class DreamEchoAppTests: XCTestCase {
    func testDreamStatusPending() {
        let dream = Dream(title: "测试梦境", description: "描述", status: .pending)
        XCTAssertTrue(dream.status.isPending)
    }
}
