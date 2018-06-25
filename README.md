# ExtendedAttributes

This library handles file extended attributes by extending `URL` struct.

<center>

[![Swift Version][swift-image]][swift-url]
[![Platform][platform-image]](#)
[![License][license-image]][license-url]
[![Release version][release-image]][release-url]

[![CocoaPods version](https://img.shields.io/cocoapods/v/ExtendedAttributes.svg)][cocoapods]
[![Carthage compatible][carthage-image]](https://github.com/Carthage/Carthage)
[![Cocoapods Downloads][cocoapods-downloads]][cocoapods]
[![Cocoapods Apps][cocoapods-apps]][cocoapods]

</center>

## Requirements

- Swift 4.0 or higher
- macOS, iOS, tvOS or Linux
- XCode 9.0

## Installation

First you must clone this project from github:

```bash
git clone https://github.com/amosavian/ExtendedAttributes
```

Then you can either install manually by adding `Sources/ExtendedAttributes ` directory to your project 
or create a `xcodeproj` file and add it as a dynamic framework:

```bash
swift package generate-xcodeproj
```

## Usage

Extended attributes only work with urls that begins with `file:///`.

### Listing

To get which extended attributes are set for file:

```swift
do {
    print(try url.listExtendedAttributes())
} catch {
    print(error.localizedDescription)
}
```

### Retrieving

To check either a specific extended attribute exists or not:

```swift
if url.hasExtendedAttribute(forName: "eaName") {
    // Do something
}
```

To retrieve raw data for an extended attribute, simply use this code as template, Please note if extended attribute doesn't exist, it will throw an error.

```swift
do {
    let data = try url.extendedAttribute(forName: "eaName")
    print(data as NSData)
} catch {
    print(error.localizedDescription)
}
```

You can retrieve values of extended attributes if they are set with standard plist binary format. This can be `String`, `Int`/`NSNumber`, `Double`, `Bool`, `URL`, `Date`, `Array` or `Dictionary`. Arrays should not contain `nil` value.

To retrieve raw data for an extended attribute, simply use this code as template:

```swift
do {
    let notes: String = try url.extendedAttributeValue(forName: "notes")
    print("Notes:", notes)
    let isDownloeded: Bool = try url.extendedAttributeValue(forName: "isdownloaded")
    print("isDownloaded:", isDownloeded)
    let originURL: URL = try url.extendedAttributeValue(forName: "originurl")
    print("Original url:", originurl)
} catch {
    print(error.localizedDescription)
}
```

or to list all values of a file:

```swift
do {
    for name in try url.listExtendedAttributes() {
        let value = try url.extendedAttributeValue(forName: name)
        print(name, ":" , value)
    }
} catch {
    print(error.localizedDescription)
}
```

### Setting attributes

To set raw data for an extended attribute:

```swift
do {
    try url.setExtendedAttribute(data: Data(bytes: [0xFF, 0x20]), forName: "data")
} catch {
    print(error.localizedDescription)
}
```

To set a value for an extended attribute:

```swift
do {
    let dictionary: [String: Any] = ["name": "Amir", "age": 30]
    try url.setExtendedAttribute(value: dictionary, forName: "identity")
} catch {
    print(error.localizedDescription)
}
```

### Removing

To remove an extended attribute:

```swift
do {
    try url.removeExtendedAttribute(forName: "identity")
} catch {
    print(error.localizedDescription)
}
```

## Known issues

Check [Issues](https://github.com/amosavian/ExtendedAttributes/issues) page.

## Contribute

We would love for you to contribute to ExtendedAttributes, check the [LICENSE][license-url] file for more info.

[swift-image]: https://img.shields.io/badge/swift-4.0-orange.svg
[swift-url]: https://swift.org/
[platform-image]: https://img.shields.io/badge/platform-macOS%7CiOS%7CtvOS%7CLinux-lightgray.svg
[license-image]: https://img.shields.io/github/license/amosavian/ExtendedAttributes.svg
[license-url]: LICENSE
[release-url]: https://github.com/amosavian/ExtendedAttributes/releases
[release-image]: https://img.shields.io/github/release/amosavian/ExtendedAttributes.svg

[carthage-image]: https://img.shields.io/badge/Carthage-compatible-4BC51D.svg
[cocoapods]: https://cocoapods.org/pods/ExtendedAttributes
[cocoapods-downloads]: https://img.shields.io/cocoapods/dt/ExtendedAttributes.svg
[cocoapods-apps]: https://img.shields.io/cocoapods/at/ExtendedAttributes.svg
[docs-image]: https://img.shields.io/cocoapods/metrics/doc-percent/ExtendedAttributes.svg
[docs-url]: http://cocoadocs.org/docsets/ExtendedAttributes/

