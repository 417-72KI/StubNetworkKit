#if !SWT_NO_XCTEST_SCAFFOLDING && compiler(<5.11)
import Testing
import XCTest

final class AllTests: XCTestCase {
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
#endif
