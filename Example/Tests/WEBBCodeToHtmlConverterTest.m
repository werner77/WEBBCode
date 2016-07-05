//
// Created by Werner Altewischer on 04/07/16.
// Copyright (c) 2016 Werner Altewischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <WEBBCode/WEBBCodeParser.h>
#import <WEBBCode/WEBBCodeToHtmlConverter.h>
#import <WEBBCode/WECopyingBBCodeToHtmlTagTransformer.h>
#import <WEBBCode/WEDefaultBBCodeToHtmlTagTransformer.h>

@interface WEBBCodeToHtmlConverterTest : XCTestCase
@end

@implementation WEBBCodeToHtmlConverterTest {

}

- (NSString *)readFromFile:(NSString *)fileName {
    NSString *inputFilePath= [[NSBundle bundleForClass:self.class] pathForResource:fileName ofType:@"txt"];
    XCTAssertNotNil(inputFilePath, @"Expected file to exist");
    NSString *input = [[NSString alloc] initWithContentsOfFile:inputFilePath encoding:NSUTF8StringEncoding error:NULL];
    XCTAssertNotNil(input, @"Expected file to be readable");
    return input;
}

- (void)testConvertHtml {

    WEBBCodeToHtmlConverter *converter = [WEBBCodeToHtmlConverter new];
    converter.transformer = [WEDefaultBBCodeToHtmlTagTransformer new];
    converter.useParagraphs = NO;

    NSString *input = [self readFromFile:@"bbcode-input1"];

    NSString *output = [converter htmlFromBBCode:input error:nil];

    NSLog(@"output: %@", output);

}

@end