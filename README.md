# ios-mobile-inbox

[![REUSE status](https://api.reuse.software/badge/github.com/emartech/ios-mobile-inbox)](https://api.reuse.software/info/github.com/emartech/ios-mobile-inbox)

With [Emarsys SDK](https://github.com/emartech/ios-emarsys-sdk), you can [fetch inbox messages](https://github.com/emartech/ios-emarsys-sdk/wiki#7-inbox) for a user.

This library is a plug and play inbox, that you can reuse and customise to your own branding.

## Setup
1. Cocoapods
```
pod 'EmarsysInbox', :git => 'https://github.com/emartech/ios-mobile-inbox.git'
```
2. Init EmarsysInboxController with new()
```swift
navigationController?.pushViewController(EmarsysInboxController.new(), animated: true)
```

## Configurable variables
You may customize the view with the static variables in `EmarsysInboxConfig` .
```swift
EmarsysInboxConfig.bodyForegroundColor = .black
```

```swift
var headerBackgroundColor: UIColor?
```

```swift
var headerForegroundColor: UIColor?
```

```swift
var bodyBackgroundColor: UIColor?
```

```swift
var bodyForegroundColor: UIColor?
```

```swift
var bodyTintColor: UIColor?
```

```swift
var bodyHighlightTintColor: UIColor?
```

```swift
var activityIndicatorColor: UIColor?
```

```swift
var favImageOff: UIImage?
```

```swift
var favImageOn: UIImage?
```

```swift
var notOpenedViewColor: UIColor?
```

```swift
var defaultImage: UIImage?
```

```swift
var highPriorityImage: UIImage?
```

## Screenshots
<img src="https://raw.githubusercontent.com/emartech/ios-mobile-inbox/master/sample.png" width="200">

## Requirements

The iOS target should be iOS 11 or higher.

## Contributing

Should you have any suggestions or bug reports, please raise an [Emarsys support request](https://help.emarsys.com/hc/en-us/articles/360012853058-Support-at-Emarsys-Raising-a-support-request).

## Code of Conduct

Please see our [Code of Conduct](https://github.com/emartech/.github/blob/main/CODE_OF_CONDUCT.md) for detail.

## Licensing

Please see our [LICENSE](https://github.com/emartech/ios-mobile-inbox/blob/master/LICENSE) for copyright and license information.

