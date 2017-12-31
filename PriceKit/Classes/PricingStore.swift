import Foundation

public class PriceStore {
    // The name of the default pricing matrix csv file.
    // Apple appends the download timestamp to the filename when you download the file from iTunes Connect,
    // which is useful information to have and should be preserved as "proof" of when the pricing table was generated.
    // If you are updating PriceKit's pricing matrix, delete the outdated CSV file, replace it with the newer CSV file,
    // and update the variable here so it points to the updated filename.
    static fileprivate let defaultPricingMatrixCsvFilename = "pricing_matrix_20171225-135611"

    // The actual pricing table, where the keys are region codes (see Apple's Locale documentation)
    // and the values are the region's tier to price lookup table.
    fileprivate lazy var tieredPricesByRegionCode: Dictionary<String, Dictionary<Tier, Price>> = [:]

    convenience init?() {
        // Open the default pricing matrix CSV.
        let priceKitBundle = Bundle(identifier: "PriceKit")
        
        guard let csvUrl = priceKitBundle?.url(forResource: PriceStore.defaultPricingMatrixCsvFilename, withExtension: "csv") else {
            return nil
        }
        
        guard let csvData = try? String(contentsOf: csvUrl, encoding: .utf8) else {
            return nil
        }
        
        self.init(contentsOfPricingMatrixCsvFile: csvData)
    }

    init?(contentsOfPricingMatrixCsvFile csvData: String) {
        var lines: [String] = []
        csvData.enumerateLines { (line, stop) in
            lines.append(line)
        }
        
        let csvSeparatorRegex = try! NSRegularExpression(
            pattern: ",(?=([^\"]*\"[^\"]*\")*[^\"]*$)",
            options: .caseInsensitive)
        
        let table = lines.map({ (line: String) -> [String] in
            line.split(separator: csvSeparatorRegex).map( { (component) -> String in String(component) })
        })
        
        // en_US@currency=USD
        
        // Parse locale info from '"Country Name (Currency Code)"' format
        let localeRegex = try! NSRegularExpression(
            pattern: "([a-zA-Z0-9_, ]+)\\((\\w+)\\)",
            options: .caseInsensitive)
        
        let localeRow = table[0]
        for columnIndex in stride(from: 1, to: localeRow.count, by: 2) {
            let localeInfo = localeRow[columnIndex]
            
            guard let matches = localeRegex.matches(in: localeInfo, range: NSMakeRange(0, localeInfo.count)).first, matches.numberOfRanges == 3 else {
                continue
            }
            
            let countryNameRange = localeInfo.range(from: matches.range(at: 1))
            let currencyCodeRange = localeInfo.range(from: matches.range(at: 2))
            
            let countryName = localeInfo[countryNameRange].trimmingCharacters(in: .whitespacesAndNewlines)
            let currencyCode = localeInfo[currencyCodeRange].trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let regionCode = RegionCodes.getRegionCode(fromCountryName: countryName) else {
                return nil
            }
            
            var tieredPrices: Dictionary<Tier, PriceInfo> = [:]
            for rowIndex in (2..<table.count) {
                let tierName = table[rowIndex][0]
                let price = table[rowIndex][columnIndex].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                
                guard let tier = Tier(rawValue: tierName), let decimalPrice = Decimal(string: price, locale: Locale(identifier: "en_US")) else {
                    return nil
                }
                
                let priceLocale = Locale(identifier: "\(regionCode)@currency=\(currencyCode)")
                tieredPrices[tier] = PriceInfo(price: decimalPrice as NSDecimalNumber, priceLocale: priceLocale)
            }
            
            self.tieredPricesByRegionCode[regionCode] = tieredPrices
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

