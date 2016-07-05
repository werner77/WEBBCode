//
// Created by Werner Altewischer on 04/07/16.
// Copyright (c) 2016 Werner Altewischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <WEBBCode/WEBBCodeParser.h>
#import <WEBBCode/WEBBCodeToHtmlConverter.h>
#import <WEBBCode/WECopyingBBCodeToHtmlTagTransformer.h>
#import <WEBBCode/WEDefaultBBCodeToHtmlTagTransformer.h>
#import "WEBBCodeTest.h"

@interface WEBBCodeToHtmlConverterTest : WEBBCodeTest
@end

@implementation WEBBCodeToHtmlConverterTest {

}

- (void)testConvertHtml {

    WEBBCodeToHtmlConverter *converter = [WEBBCodeToHtmlConverter new];
    converter.transformer = [WEDefaultBBCodeToHtmlTagTransformer new];
    converter.useParagraphs = NO;

    NSString *input = [self readFromFile:@"bbcode-input2"];

    NSString *output = [converter htmlFromBBCode:input error:nil];

    NSString *expectedOutput = [self readFromFile:@"bbcode-output2"];

    NSLog(@"output:\n%@", output);

    XCTAssertEqualObjects(expectedOutput, output, @"Expected output to be correct");

}

@end