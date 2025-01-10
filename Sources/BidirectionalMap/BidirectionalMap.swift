public struct BidirectionalMap<Left: Hashable, Right: Hashable>: Collection {
    
    // ============================================================================ //
    // MARK: Type Aliases
    // ============================================================================ //
    
    /// The type of the left-right value pair.
    public typealias Element = (left: Left, right: Right)
    
    /// The type of the index.
    public typealias Index = DictionaryIndex<Left, Right>
    
    // ============================================================================ //
    // MARK: Initialization
    // ============================================================================ //
    
    public init() {
        self._leftToRightValues = Dictionary()
        self._rightToLeftValues = Dictionary()
    }
    
    public init(minimumCapacity: Int) {
        self._leftToRightValues = Dictionary(minimumCapacity: minimumCapacity)
        self._rightToLeftValues = Dictionary(minimumCapacity: minimumCapacity)
    }
    
    public init(uniquePairs pairs: any Sequence<Self.Element>) {
        self.init(minimumCapacity: pairs.underestimatedCount)
        
        for (left, right) in pairs {
            precondition(
                !self.containsLeft(left) && !self.containsRight(right),
                "Sequence of left-right value pairs contains duplicate keys"
            )
            
            self.associate(left: left, right: right)
        }
    }
    
    // ============================================================================ //
    // MARK: Left & Right Values
    // ============================================================================ //
    
    public var leftValues: AnyCollection<Left> {
        return AnyCollection(self._leftToRightValues.keys)
    }
    
    public var rightValues: AnyCollection<Right> {
        return AnyCollection(self._rightToLeftValues.keys)
    }
    
    // ============================================================================ //
    // MARK: Associations
    // ============================================================================ //
    
    @discardableResult
    public mutating func associate(
        left: Left,
        right: Right
    ) -> (previousRight: Right?, previousLeft: Left?)  {
        let previousRight = self.disassociateLeft(left)
        let previousLeft = self.disassociateRight(right)
        
        self._leftToRightValues[left] = right
        self._rightToLeftValues[right] = left
        
        return (previousRight, previousLeft)
    }
    
    @discardableResult
    public mutating func disassociateLeft(_ left: Left) -> Right? {
        guard let right = self._leftToRightValues.removeValue(forKey: left) else { return nil }
        self._rightToLeftValues.removeValue(forKey: right)
        return right
    }
    
    @discardableResult
    public mutating func disassociateRight(_ right: Right) -> Left? {
        guard let left = self._rightToLeftValues.removeValue(forKey: right) else { return nil }
        self._leftToRightValues.removeValue(forKey: left)
        return left
    }
    
    public mutating func disassociateAll(keepCapacity: Bool = false) {
        self._leftToRightValues.removeAll(keepingCapacity: keepCapacity)
        self._rightToLeftValues.removeAll(keepingCapacity: keepCapacity)
    }
    
    // ============================================================================ //
    // MARK: Value-based Access
    // ============================================================================ //
    
    public subscript(left left: Left) -> Right? {
        get {
            return self._leftToRightValues[left]
        }
        set(newRight) {
            if let newRight {
                self.associate(left: left, right: newRight)
            } else {
                self.disassociateLeft(left)
            }
        }
    }
    
    public subscript(right right: Right) -> Left? {
        get {
            return self._rightToLeftValues[right]
        }
        set(newLeft) {
            if let newLeft {
                self.associate(left: newLeft, right: right)
            } else {
                self.disassociateRight(right)
            }
        }
    }
    
    // ============================================================================ //
    // MARK: Value Containment
    // ============================================================================ //
    
    public func containsLeft(_ left: Left) -> Bool {
        return self[left: left] != nil
    }
    
    public func containsRight(_ right: Right) -> Bool {
        return self[right: right] != nil
    }
    
    // ============================================================================ //
    // MARK: Indices
    // ============================================================================ //
    
    public var startIndex: Index {
        return self._leftToRightValues.startIndex
    }
    
    public var endIndex: Index {
        return self._leftToRightValues.endIndex
    }
    
    public func index(after i: Index) -> Index {
        return self._leftToRightValues.index(after: i)
    }
    
    public func indexForLeft(_ left: Left) -> Index? {
        return self._leftToRightValues.index(forKey: left)
    }
    
    public func indexForRight(_ right: Right) -> Index? {
        return self[right: right].flatMap { left in
            return self.indexForLeft(left)
        }
    }
    
    // ============================================================================ //
    // MARK: Index-based Access
    // ============================================================================ //
    
    public subscript(position: Index) -> Element {
        let (left, right) = self._leftToRightValues[position]
        return (left, right)
    }
    
    // ============================================================================ //
    // MARK: Inversed Map
    // ============================================================================ //
    
    public func inversed() -> BidirectionalMap<Right, Left> {
        var result = BidirectionalMap<Right, Left>()
        result._leftToRightValues = self._rightToLeftValues
        result._rightToLeftValues = self._leftToRightValues
        return result
    }
    
    // ============================================================================ //
    // MARK: Internal Storage
    // ============================================================================ //
    
    /// The backing storage for the mapping from left to right values.
    private var _leftToRightValues: [Left: Right]
    
    /// The backing storage for the mapping from right to left values.
    private var _rightToLeftValues: [Right: Left]
    
}

extension BidirectionalMap: CustomStringConvertible {
    public var description: String {
        return self._leftToRightValues.description
    }
}

extension BidirectionalMap: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral pairs: (Left, Right)...) {
        self.init(uniquePairs: pairs.lazy.map { ($0, $1) })
    }
}

extension BidirectionalMap: Equatable where Left: Equatable, Right: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs._leftToRightValues == rhs._leftToRightValues
    }
}
