import XCTest
@testable import DreamEchoApp

final class DreamEchoAppTests: XCTestCase {
    func testProgressMessage() {
        XCTAssertEqual(DreamStatus.completed.progressMessage, "模型生成完成")
        XCTAssertEqual(DreamStatus.failed.progressMessage, "生成失败，请重试")
    }
}
