import Foundation

public protocol Price {
    var price: NSDecimalNumber { get }
    var priceLocale: Locale { get }
}

public extension Price {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        
        return formatter.string(from: self.price)!
    }
}
