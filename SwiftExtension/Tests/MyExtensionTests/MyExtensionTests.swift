import XCTest
@testable import MyExtension

final class MyExtensionTests: XCTestCase {
    func testExtensionModuleLoads() {
        XCTAssertNotNil(SpinningCube.self)
    }
}
