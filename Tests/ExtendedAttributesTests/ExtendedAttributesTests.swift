import XCTest
@testable import ExtendedAttributes

final class ExtendedAttributesTests: XCTestCase {
    func testExtendedAttributes() {
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
        
        do {
            try "Hello World!".data(using: .utf8)!.write(to: url)
            
            try url.setExtendedAttribute(data: Data(bytes: [0xFF, 0x20]), forName: "DataAttrib")
            XCTAssertTrue(url.hasExtendedAttribute(forName: "DataAttrib"))
            let data = try url.extendedAttribute(forName: "DataAttrib")
            XCTAssertEqual([UInt8](data), [0xFF, 0x20])
            try url.removeExtendedAttribute(forName: "DataAttrib")
            XCTAssertFalse(url.hasExtendedAttribute(forName: "DataAttrib"))
            XCTAssertThrowsError(try url.extendedAttribute(forName: "DataAttrib"))
            
            let date = Date()
            try url.setExtendedAttribute(value: date, forName: "DateAttrib")
            XCTAssertEqual(try url.extendedAttributeValue(forName: "DateAttrib"), date)
            
            let str = "This is test."
            try url.setExtendedAttribute(value: str, forName: "StringAttrib")
            XCTAssertEqual(try url.extendedAttributeValue(forName: "StringAttrib"), str)
            
            try url.setExtendedAttribute(value: true, forName: "BoolAttrib")
            XCTAssertEqual(try url.extendedAttributeValue(forName: "BoolAttrib"), true)
            
            let num = 1453
            try url.setExtendedAttribute(value: num, forName: "NumericAttrib")
            XCTAssertEqual(try url.extendedAttributeValue(forName: "NumericAttrib"), num)
            
            let array: [Int] = [1970, 622, -323]
            try url.setExtendedAttribute(value: array, forName: "ArrayAttrib")
            XCTAssertEqual(try url.extendedAttributeValue(forName: "ArrayAttrib"), array)
            
            let dictionary: [String: Any] = ["name": "Amir", "age": 30]
            try url.setExtendedAttribute(value: dictionary, forName: "DictionaryAttrib")
            let retrDic: [String: Any] = try url.extendedAttributeValue(forName: "DictionaryAttrib")
            XCTAssertEqual(retrDic["name"] as? String, dictionary["name"] as? String)
            XCTAssertEqual(retrDic["age"] as? Int, dictionary["age"] as? Int)
            
            let vnil: Int? = nil
            XCTAssertThrowsError(try url.setExtendedAttribute(value: vnil, forName: "NilAttrib"))
            
            XCTAssertEqual(try url.listExtendedAttributes(), [
                "ArrayAttrib",
                "BoolAttrib",
                "DateAttrib",
                "DictionaryAttrib",
                "NumericAttrib",
                "StringAttrib",
                ])
            try FileManager.default.removeItem(at: url)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }


    static var allTests = [
        ("testExtendedAttributes", testExtendedAttributes),
    ]
}
