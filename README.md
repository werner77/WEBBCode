# WEBBCode

[![CI Status](http://img.shields.io/travis/Werner Altewischer/WEBBCode.svg?style=flat)](https://travis-ci.org/Werner Altewischer/WEBBCode)
[![Version](https://img.shields.io/cocoapods/v/WEBBCode.svg?style=flat)](http://cocoapods.org/pods/WEBBCode)
[![License](https://img.shields.io/cocoapods/l/WEBBCode.svg?style=flat)](http://cocoapods.org/pods/WEBBCode)
[![Platform](https://img.shields.io/cocoapods/p/WEBBCode.svg?style=flat)](http://cocoapods.org/pods/WEBBCode)

This is a lean and mean SAX style parser for BBCode written in Objective C/C.

It has support for output to HTML and NSAttributedString (work in progress) for simple BBCode.

It is totally pluggable and extensible to allow for full customization.

The pod has two sub specs:

Core: which contains the BBCode parser and model classes.
HTML: which contains support for transformation to HTML.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Example usage to parse:

```objc

WEBBCodeParser *parser = [WEBBCodeParser new];
parser.encoding = NSUTF8StringEncoding;
parser.delegate = self;

NSData *data = [NSData dataWithContentsOfFile:@"somefile"];
[parser parseData:data error:nil];

```

Example to convert BBCode to HTML:

```objc

WEBBCodeToHtmlConverter *converter = [WEBBCodeToHtmlConverter new];
converter.transformer = [WEDefaultBBCodeToHtmlTagTransformer new];
converter.useParagraphs = NO;

NSString *input = @"some [b]bb code[/b]"";
NSError *error = nil;
NSString *output = [converter htmlFromBBCode:input error:&error];

if (output == nil) {
    NSLog(@"Error occurred: %@", error);
}

```

Also see the test cases for more code examples.

## Requirements

## Installation

WEBBCode is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "WEBBCode"
```

## Author

Werner Altewischer, werner.altewischer@gmail.com

## License

WEBBCode is available under the MIT license. See the LICENSE file for more info.
