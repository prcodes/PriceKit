import Foundation

extension String {
    // Creates a String Range from an NSRange.
    func range(from nsRange: NSRange) -> Range<String.Index> {
        let start = self.index(self.startIndex, offsetBy: nsRange.location)
        let end = self.index(start, offsetBy: nsRange.length)
        
        return start..<end
    }
    
    // Splits a string by a regex separator.
    func split(separator regex: NSRegularExpression) -> [Substring] {
        var components: [Substring] = []
        let delimiterMatches = regex.matches(in: self, options: .withoutAnchoringBounds , range: NSMakeRange(0, self.count))
        
        var currentComponentStartIndex: String.Index = self.startIndex
        
        for delimiterMatch in delimiterMatches {
            let delimiterRange = delimiterMatch.range
            
            let currentComponentEndIndex = self.index(self.startIndex, offsetBy: delimiterRange.location)
            
            let component = self[currentComponentStartIndex..<currentComponentEndIndex]
            components.append(component)
            
            currentComponentStartIndex = self.index(currentComponentEndIndex, offsetBy: delimiterRange.length)
        }
        
        return components
    }
}
