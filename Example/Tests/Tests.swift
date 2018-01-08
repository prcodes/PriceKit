import Quick
import Nimble
import PriceKit

class PriceKitSpec: QuickSpec {
    override func spec() {
        describe("validates CSV file parsing") {
            it("fails when file is empty") {
                let store = PriceStore(contentsOfPricingMatrixCsvFile: "")
                expect(store).to(beNil())
            }
            
            it("fails when file is malformed") {
                let store = PriceStore(contentsOfPricingMatrixCsvFile: ",,,,")
                expect(store).to(beNil())
            }
        }
        
        describe("validates prices") {
            print(Locale.availableIdentifiers)
            
            it("succeeds for default PriceStore") {
                let store = PriceStore()
                expect(store).toNot(beNil())
            }
            
            it("can get valid US price information") {
                let csvData = """
                ,"United States (USD)"
                ,"Price"
                Free,"0.00"
                Tier 1,"0.99"
                """
                
                let store = PriceStore(contentsOfPricingMatrixCsvFile: csvData)
                expect(store).toNot(beNil())
                
                let priceLocale = Locale(identifier: "en_US")
                
                let freeTierPrice = store!.getPrice(of: .free, inPriceLocale: priceLocale)
                expect(freeTierPrice).toNot(beNil())
                
                expect(freeTierPrice?.price).to(equal(NSDecimalNumber(value: 0)))
                expect(freeTierPrice?.priceLocale.regionCode).to(equal("US"))
                expect(freeTierPrice?.priceLocale.currencyCode).to(equal("USD"))
                
                let tier1Price = store!.getPrice(of: .tier1, inPriceLocale: priceLocale)
                expect(tier1Price).toNot(beNil())
                
                expect(tier1Price?.price).to(equal(NSDecimalNumber(value: 0.99)))
                expect(tier1Price?.priceLocale.regionCode).to(equal("US"))
                expect(tier1Price?.priceLocale.currencyCode).to(equal("USD"))
            }
            
            it("can get valid non-US price information") {
                let csvData = """
                ,"France (EUR)"
                ,"Price"
                Free,"0.00"
                Tier 1,"0.99"
                """
                
                let store = PriceStore(contentsOfPricingMatrixCsvFile: csvData)
                expect(store).toNot(beNil())
                
                let priceLocale = Locale(identifier: "fr_FR")
                
                let freeTierPrice = store!.getPrice(of: .free, inPriceLocale: priceLocale)
                expect(freeTierPrice).toNot(beNil())
                
                expect(freeTierPrice?.price).to(equal(NSDecimalNumber(value: 0)))
                expect(freeTierPrice?.priceLocale.regionCode).to(equal("FR"))
                expect(freeTierPrice?.priceLocale.currencyCode).to(equal("EUR"))
                
                let tier1Price = store!.getPrice(of: .tier1, inPriceLocale: priceLocale)
                expect(tier1Price).toNot(beNil())
                
                expect(tier1Price?.price).to(equal(NSDecimalNumber(value: 0.99)))
                expect(tier1Price?.priceLocale.regionCode).to(equal("FR"))
                expect(tier1Price?.priceLocale.currencyCode).to(equal("EUR"))
            }
            
            it("can get valid price information with currency override") {
                let csvData = """
                ,"United States (CNY)"
                ,"Price"
                Free,"0.00"
                Tier 1,"0.99"
                """
                
                let store = PriceStore(contentsOfPricingMatrixCsvFile: csvData)
                expect(store).toNot(beNil())
                
                let priceLocale = Locale(identifier: "en_US")
                
                let freeTierPrice = store!.getPrice(of: .free, inPriceLocale: priceLocale)
                expect(freeTierPrice).toNot(beNil())
                
                expect(freeTierPrice?.price).to(equal(NSDecimalNumber(value: 0)))
                expect(freeTierPrice?.priceLocale.regionCode).to(equal("US"))
                expect(freeTierPrice?.priceLocale.currencyCode).to(equal("CNY"))
                
                let tier1Price = store!.getPrice(of: .tier1, inPriceLocale: priceLocale)
                expect(tier1Price).toNot(beNil())
                
                expect(tier1Price?.price).to(equal(NSDecimalNumber(value: 0.99)))
                expect(tier1Price?.priceLocale.regionCode).to(equal("US"))
                expect(tier1Price?.priceLocale.currencyCode).to(equal("CNY"))
            }
        }
    }
}

