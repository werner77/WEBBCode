//
// Created by Werner Altewischer on 02/07/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <WEBBCode/WEBBCodeParser.h>
#import <WEBBCode/WEBBCodeTag.h>
#import "WEBBCodeTest.h"

@interface WEBBCodeParserTest : WEBBCodeTest<WEBBCodeParserDelegate>

@end

@implementation WEBBCodeParserTest {
    NSMutableString *_output;
}

- (NSString *)readFromFile:(NSString *)fileName {
    NSString *inputFilePath= [[NSBundle bundleForClass:self.class] pathForResource:fileName ofType:@"txt"];
    XCTAssertNotNil(inputFilePath, @"Expected file to exist");
    NSString *input = [[NSString alloc] initWithContentsOfFile:inputFilePath encoding:NSUTF8StringEncoding error:NULL];
    XCTAssertNotNil(input, @"Expected file to be readable");
    return input;
}

- (void)parseInputFile:(NSString *)inputFile withExpectedOutputFile:(NSString *)outputFile {
    NSString *input = [self readFromFile:inputFile];
    NSString *output = [self readFromFile:outputFile];
    [self parseInput:input withExpectedOutput:output];
}

- (void)parseInput:(NSString *)input withExpectedOutput:(NSString *)output {
    WEBBCodeParser *parser = [WEBBCodeParser new];
    parser.delegate = self;

    NSUInteger batchSize = 10;

    unichar *buffer = malloc(sizeof(unichar) * batchSize);
    NSUInteger bufferPos = 0;
    NSUInteger pos = 0;

    _output = [NSMutableString new];

    NSLog(@"Input:\n%@", input);

    while (pos < input.length) {
        for (bufferPos = 0; bufferPos < batchSize && pos < input.length; bufferPos++) {
            unichar c = [input characterAtIndex:pos++];
            buffer[bufferPos] = c;
        }

        NSString *s = [[NSString alloc] initWithCharacters:buffer length:bufferPos];
        [parser parseData:[s dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    }

    free(buffer);

    NSLog(@"Output:\n%@", _output);

    XCTAssertEqualObjects(output, _output, @"Expected output to be correct");
}

- (void)testSimpleTag {
    [self parseInput:@"[img=100x200]aap[/img]" withExpectedOutput:@"<img __default=\"100x200\">aap</img>"];
}

- (void)testEscapedAttribute {
    [self parseInput:@"[url href='bla\\'\"\\[\\]\\\\']noot[/url]" withExpectedOutput:@"<url href=\"bla'\\\"[]\\\">noot</url>"];
}

- (void)testEscapedText {
    [self parseInput:@"[url href='bla']noot\\]\\[\\\\[/url]" withExpectedOutput:@"<url href=\"bla\">noot][\\</url>"];
}

- (void)testDocument1 {
    [self parseInputFile:@"bbcode-input1" withExpectedOutputFile:@"bbcode-output1"];
}

- (void)parser:(WEBBCodeParser *)parser didFindEndTag:(NSString *)tag {
    [_output appendFormat:@"</%@>", tag];
}

- (void)parser:(WEBBCodeParser *)parser didFindText:(NSString *)text {
    [_output appendString:text];
}

- (void)parser:(WEBBCodeParser *)parser didFindStartTag:(WEBBCodeTag *)tag {
    [_output appendFormat:@"<%@", tag.tagName];

    for (WEBBCodeAttribute* attribute in tag.attributes.attributes) {
        NSString *attributeKey = attribute.name;
        NSString *attributeValue = attribute.value;
        attributeValue = [attributeValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        [_output appendFormat:@" %@=\"%@\"", attributeKey, attributeValue];
    }
    [_output appendString:@">"];
}

- (void)parserDidFindLineBreak:(WEBBCodeParser *)parser {
    [_output appendString:@"\n"];
}

@end