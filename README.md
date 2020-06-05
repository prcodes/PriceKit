# PriceKit

[![CI Status](http://img.shields.io/travis/prcodes/PriceKit.svg?style=flat)](https://travis-ci.org/prcodes/PriceKit)
[![Version](https://img.shields.io/cocoapods/v/PriceKit.svg?style=flat)](http://cocoapods.org/pods/PriceKit)
[![License](https://img.shields.io/cocoapods/l/PriceKit.svg?style=flat)](http://cocoapods.org/pods/PriceKit)
[![Platform](https://img.shields.io/cocoapods/p/PriceKit.svg?style=flat)](http://cocoapods.org/pods/PriceKit)

## How To Use

Get price for a specific tier in specific locale:

```
let store = PriceStore()
let priceLocale = Locale(identifier: "en_US")
let price = store?.getPrice(of: .tier1, inPriceLocale: priceLocale)
print(price?.price)
print(price?.priceLocale)
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Also, see [SKProduct+Locale.swift](./Example/Extensions/SKProduct+Locale.swift) extension. 

## Requirements

## Installation

PriceKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PriceKit'
```

## Author

Pedro R, 32828869+prcodes@users.noreply.github.com

## License

PriceKit is available under the MIT license. See the LICENSE file for more info.
