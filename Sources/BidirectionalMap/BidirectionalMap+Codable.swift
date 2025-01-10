extension BidirectionalMap: Codable where Left: Codable, Right: Codable {
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var pairs = [Element]()
        
        while !container.isAtEnd {
            let left = try container.decode(Left.self)
            let right = try container.decode(Right.self)
            pairs.append((left, right))
        }
        
        self.init(uniquePairs: pairs)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for (left, right) in self {
            try container.encode(left)
            try container.encode(right)
        }
    }
    
}
