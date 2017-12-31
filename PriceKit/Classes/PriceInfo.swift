class PriceInfo: Price {
    let price: NSDecimalNumber
    let priceLocale: Locale
    
    init(price: NSDecimalNumber, priceLocale: Locale) {
        self.price = price
        self.priceLocale = priceLocale
    }
}
