import BidirectionalMap
import XCTest

final class BidirectionalMapTests: XCTestCase {
    
    // ============================================================================ //
    // MARK: Initialization
    // ============================================================================ //
    
    func testInitializationUsingDictionaryLiteral() {
        let actual: BidirectionalMap<String, Int> = [
            "A": 1,
            "B": 2,
            "C": 3
        ]
        
        let expected = BidirectionalMap<String, Int>(uniquePairs: [
            (left: "A", right: 1),
            (left: "B", right: 2),
            (left: "C", right: 3)
        ])
        
        XCTAssertEqual(actual, expected)
    }
    
    // ============================================================================ //
    // MARK: Accessing Content
    // ============================================================================ //
    
    func testAccessingContent() {
        let map: BidirectionalMap<String, Int> = [
            "A": 1,
            "B": 2,
            "C": 3
        ]
        
        XCTAssertEqual(map.count, 3)
        
        XCTAssertEqual(Set(map.leftValues), ["A", "B", "C"])
        XCTAssertEqual(Set(map.rightValues), [1, 2, 3])
        
        XCTAssertTrue(map.containsLeft("A"))
        XCTAssertTrue(map.containsLeft("B"))
        XCTAssertTrue(map.containsLeft("C"))
        
        XCTAssertTrue(map.containsRight(1))
        XCTAssertTrue(map.containsRight(2))
        XCTAssertTrue(map.containsRight(3))
        
        XCTAssertEqual(map[left: "A"], 1)
        XCTAssertEqual(map[left: "B"], 2)
        XCTAssertEqual(map[left: "C"], 3)
        
        XCTAssertEqual(map[right: 1], "A")
        XCTAssertEqual(map[right: 2], "B")
        XCTAssertEqual(map[right: 3], "C")
        
        XCTAssertEqual(map.indexForLeft("A"), map.indexForRight(1))
        XCTAssertEqual(map.indexForLeft("B"), map.indexForRight(2))
        XCTAssertEqual(map.indexForLeft("C"), map.indexForRight(3))
        
        XCTAssertEqual(map.indexForLeft("A").flatMap({ map[$0] })?.left, "A")
        XCTAssertEqual(map.indexForLeft("B").flatMap({ map[$0] })?.left, "B")
        XCTAssertEqual(map.indexForLeft("C").flatMap({ map[$0] })?.left, "C")
        
        XCTAssertEqual(map.indexForLeft("A").flatMap({ map[$0] })?.right, 1)
        XCTAssertEqual(map.indexForLeft("B").flatMap({ map[$0] })?.right, 2)
        XCTAssertEqual(map.indexForLeft("C").flatMap({ map[$0] })?.right, 3)
    }
    
    // ============================================================================ //
    // MARK: Modifications
    // ============================================================================ //
    
    func testModifications() {
        var map: BidirectionalMap<String, Int> = [
            "A": 1,
            "B": 2,
            "C": 3,
            "D": 4,
            "E": 5
        ]
        // => [A: 1, B: 2, C: 3, D: 4, E: 5]
        
        XCTAssertEqual(map.count, 5)
        XCTAssertEqual(map[left: "A"], 1)
        XCTAssertEqual(map[left: "B"], 2)
        XCTAssertEqual(map[left: "C"], 3)
        XCTAssertEqual(map[left: "D"], 4)
        XCTAssertEqual(map[left: "E"], 5)
        
        map.associate(left: "F", right: 6)
        // => [A: 1, B: 2, C: 3, D: 4, E: 5, F: 6]
        
        XCTAssertEqual(map.count, 6)
        XCTAssertEqual(map[left: "F"], 6)
        XCTAssertEqual(map[right: 6], "F")
        
        let valueForB = map.disassociateLeft("B")
        // => [A: 1, C: 3, D: 4, E: 5, F: 6]
        
        XCTAssertEqual(map.count, 5)
        XCTAssertEqual(valueForB, 2)
        XCTAssertNil(map[left: "B"])
        XCTAssertNil(map[right: 2])
        
        let valueFor3 = map.disassociateRight(3)
        // => [A: 1, D: 4, E: 5, F: 6]
        
        XCTAssertEqual(map.count, 4)
        XCTAssertEqual(valueFor3, "C")
        XCTAssertNil(map[left: "C"])
        XCTAssertNil(map[right: 3])
        
        let (valueForD, valueFor7) = map.associate(left: "D", right: 7)
        // => [A: 1, D: 7, E: 5, F: 6]
        
        XCTAssertEqual(map.count, 4)
        XCTAssertEqual(valueForD, 4)
        XCTAssertNil(valueFor7)
        XCTAssertEqual(map[left: "D"], 7)
        XCTAssertEqual(map[right: 7], "D")
        XCTAssertNil(map[right: 4])
        
        let (valueForG, valueFor5) = map.associate(left: "G", right: 5)
        // => [A: 1, D: 7, F: 6, G: 5]
        
        XCTAssertEqual(map.count, 4)
        XCTAssertNil(valueForG)
        XCTAssertEqual(valueFor5, "E")
        XCTAssertEqual(map[left: "G"], 5)
        XCTAssertEqual(map[right: 5], "G")
        XCTAssertNil(map[left: "E"])
        
        let (valueForA, valueFor6) = map.associate(left: "A", right: 6)
        // => [A: 6, D: 7, G: 5]
        
        XCTAssertEqual(map.count, 3)
        XCTAssertEqual(valueForA, 1)
        XCTAssertEqual(valueFor6, "F")
        XCTAssertEqual(map[left: "A"], 6)
        XCTAssertEqual(map[right: 6], "A")
        XCTAssertNil(map[left: "F"])
        XCTAssertNil(map[right: 1])
        
        map.disassociateAll()
        // => [:]
        
        XCTAssertTrue(map.isEmpty)
    }
    
    // ============================================================================ //
    // MARK: Inversion
    // ============================================================================ //
    
    func testInversion() {
        let map: BidirectionalMap<String, Int> = [
            "A": 1,
            "B": 2,
            "C": 3
        ]
        
        let actual = map.inversed()
        
        let expected: BidirectionalMap<Int, String> = [
            1: "A",
            2: "B",
            3: "C"
        ]
        
        XCTAssertEqual(actual, expected)
    }
    
    // ============================================================================ //
    // MARK: Codable Conformance
    // ============================================================================ //
    
    func testCodable() throws {
        let originalMap: BidirectionalMap<String, Int> = [
            "A": 1,
            "B": 2,
            "C": 3
        ]
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalMap)
        
        let decoder = JSONDecoder()
        let decodedMap = try decoder.decode(BidirectionalMap<String, Int>.self, from: encodedData)
        
        XCTAssertEqual(originalMap, decodedMap)
    }
    
}
