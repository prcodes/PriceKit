//
//  SKProduct+Locale.swift
//
//
//  Created by Alex Kovalov on 01.06.2020.
//  Copyright © 2020 Alex Kovalov. All rights reserved.
//

import Foundation
import StoreKit
import PriceKit

public extension SKProduct {
    
    func priceNumberInLocale(_ locale: Locale) -> NSNumber? {
        
        guard let store = PriceStore() else {
            return nil
        }
        
        for tier in Tier.allCases {
            if let tierPrice = store.getPrice(of: tier, inPriceLocale: priceLocale),
                tierPrice.price == self.price {
                
                if let otherLocalePrice = store.getPrice(of: tier, inPriceLocale: locale) {
                    return otherLocalePrice.price
                }
            }
        }
        return nil
    }
    
    func formattedPriceInLocale(_ locale: Locale) -> String? {
        
        guard let price = priceNumberInLocale(locale) else {
            return nil
        }
        
        let formatter = priceFormatter(locale: locale)
        return formatter.string(from: price)
    }
    
    func priceFormatter(locale: Locale) -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
}
