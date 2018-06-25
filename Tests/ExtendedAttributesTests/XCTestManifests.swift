import XCTest

#if !canImport(Darwin)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ExtendedAttributesTests.allTests),
    ]
}
#endif
