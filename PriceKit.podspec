#
# Be sure to run `pod lib lint PriceKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PriceKit'
  s.version          = '1.1.0'
  s.summary          = 'Get App Store product prices by tier and locale.'

  s.description      = <<-DESC
  Get App Store prices by tier and locale.
  Use PriceKit if you have a temporarily discounted SKProduct and you want to
  to display the regular price next to the discount price (strikethrough pricing).
  Use PriceKit to get the product's regular price given the product's tier and price locale.
  Pricing information is generated from Apple's product pricing matrix CSV available from iTunes Connect.
  NOTE: By default, pricing information is baked into the pod and is not dynamically fetched from iTunes Connect or any other web service.
  As such, PriceKit's pricing data may become out of date at any time and there are no guarantees of the accuracy of the data. Use at your own risk.
  Keep your pod regularly updated, or host the pricing matrix CSV on your own web service and regularly update it from iTunes Connect, passing it into PriceKit for parsing.
                       DESC

  s.homepage         = 'https://github.com/prcodes/PriceKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pedro R' => '32828869+prcodes@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/prcodes/PriceKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PriceKit/Classes/**/*'
  
  s.resource_bundles = {
    'PriceKit' => ['PriceKit/Resources/*']
  }
end
