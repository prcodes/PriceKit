import Foundation

public class PriceStore {
    // The name of the default pricing matrix csv file.
    // Apple appends the download timestamp to the filename when you download the file from App Store Connect,
    // which is useful information to have and should be preserved as "proof" of when the pricing table was generated.
    // If you are updating PriceKit's pricing matrix, delete the outdated CSV file, replace it with the newer CSV file,
    // and update the variable here so it points to the updated filename.
    static fileprivate let defaultPricingMatrixCsvFilename = "pricing_matrix_20200605-053929"

    // The actual pricing table, where the keys are region codes (see Apple's Locale documentation)
    // and the values are the region's tier to price lookup table.
    fileprivate lazy var tieredPricesByRegionCode: Dictionary<String, Dictionary<Tier, Price>> = [:]

    // Loads default price information from the PriceKit bundle.
    public convenience init?() {
        let priceKitBundle = Bundle(for: PriceStore.self)

        // Open the default pricing matrix CSV.
        guard let csvUrl = priceKitBundle.url(forResource: PriceStore.defaultPricingMatrixCsvFilename, withExtension: "csv", subdirectory: "PriceKit.bundle") else {
            return nil
        }
        
        guard let csvData = try? String(contentsOf: csvUrl, encoding: .utf8) else {
            return nil
        }
        
        self.init(contentsOfPricingMatrixCsvFile: csvData)
    }

    // Loads price information from user-provided pricing matrix CSV
    public init?(contentsOfPricingMatrixCsvFile csvData: String) {
        // Read the lines
        var lines: [String] = []
        csvData.enumerateLines { (line, stop) in
            print(line)
            lines.append(line)
        }
        
        // Extract the columns of the CSV table header, which is in the follwing format:
        // "United States (USD)", Korea, Republic of (USD)","Spain (EUR)"
        // Because each entry can contain commas, we can't just do a simple comma-separated split.
        let csvSeparatorRegex = try! NSRegularExpression(
            pattern: ",(?=([^\"]*\"[^\"]*\")*[^\"]*$)",
            options: .caseInsensitive)
        
        // Convert the raw CSV data into a simple 2D String array.
        let table: [[String]] = lines.map({ (line: String) -> [String] in
            line.split(separator: csvSeparatorRegex).map( { (component) -> String in String(component) })
        })

        // We need at least 1 locale row and one tier row.
        guard table.count > 1 else {
            return nil
        }
        
        // Regex to capture country name and currency code from '"Country Name (Currency Code)"' strings.
        let localeRegex = try! NSRegularExpression(
            pattern: "([a-zA-Z0-9_, ]+)\\((\\w+)\\)",
            options: .caseInsensitive)
        
        // First row contains country/currency locale info.
        let localeRow = table[0]
        print(localeRow.count)
        
        // Visit odd-numbered column indexes to get price information for each country.
        // Even-numbered column indexes contain developer proceeds information for each country. Proceeds are not parsed by PriceKit.
        for columnIndex in stride(from: 1, to: localeRow.count, by: 2) {
            let localeInfo: String = localeRow[columnIndex]
            
            // Match for country name and currency code.
            guard let matches = localeRegex.matches(in: localeInfo, range: NSMakeRange(0, localeInfo.count)).first, matches.numberOfRanges == 3 else {
                return nil
            }
            
            let countryNameRange = localeInfo.range(from: matches.range(at: 1))
            let currencyCodeRange = localeInfo.range(from: matches.range(at: 2))
            
            let countryName = localeInfo[countryNameRange].trimmingCharacters(in: .whitespacesAndNewlines)
            let currencyCode = localeInfo[currencyCodeRange].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Map the country name to the country/region code compatible with Locale.
            guard let regionCode = RegionCodes.getRegionCode(fromCountryName: countryName) else {
                return nil
            }
            
            // Build up the tier/price table for this country.
            var tieredPrices: Dictionary<Tier, PriceInfo> = [:]
            for rowIndex in (2..<table.count) {
                let tierName = table[rowIndex][0]
                let price = table[rowIndex][columnIndex].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                
                // Parse the Tier and decimal price.
                // This assumes the pricing matrix CSV from Apple is always localized for en_US.
                // This may fail if the pricing matrix CSV is localized to the developer's iTunes Connect account locale.
                guard let tier = Tier(rawValue: tierName), let decimalPrice = Decimal(string: price, locale: Locale(identifier: "en_US")) else {
                    return nil
                }
                
                // Create the price locale, including the currency code override.
                // For some locales, the currency in the pricing matrix is NOT the country's native currency.
                // For example, for Korea the price currency is USD, not the native KRW.
                // A country's native currency can be overriden by appending '@currency=FOO' to the Locale identifier.
                // A valid language is required in a Locale - just use English, language is not important when determining price.
                let priceLocale = Locale(identifier: "en_\(regionCode)@currency=\(currencyCode)")
                guard let localeCurrencyCode = priceLocale.currencyCode, priceLocale.regionCode != nil, localeCurrencyCode == currencyCode else {
                    // This currency override trick isn't well documented, so fail loudly if it stops working.
                    return nil
                }
                
                tieredPrices[tier] = PriceInfo(price: decimalPrice as NSDecimalNumber, priceLocale: priceLocale)
            }
            
            self.tieredPricesByRegionCode[regionCode] = tieredPrices
        }
        
        guard self.tieredPricesByRegionCode.count > 0 else {
            return nil
        }
    }
    
    public func getPrice(of tier: Tier, inPriceLocale priceLocale: Locale) -> Price? {
        guard let regionCode = priceLocale.regionCode,
            let tieredPrices = self.tieredPricesByRegionCode[regionCode],
            let price = tieredPrices[tier] else {
                return nil
        }
        
        return price
    }
}
