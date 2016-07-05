//
//  WEBBCodeParser.h
//  WEBBCodeParser
//
//  Created by Werner Altewischer on 03/07/16.
//  Copyright (c) 2016 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WEBBCode/WEBBCodeAttributes.h>

@class WEBBCodeParser;
@class WEBBCodeTag;

typedef NS_ENUM(NSUInteger, WEBBCodeParserStatus) {
    WEBBCodeParserStatusNone = 0,  //!< No status
    WEBBCodeParserStatusOK = 1, //!< Parsed OK
    WEBBCodeParserStatusInsufficientData = 2, //!< There was insufficient data
    WEBBCodeParserStatusError = 3 //!< Parser errored
};

@protocol WEBBCodeParserDelegate<NSObject>

- (void)parser:(WEBBCodeParser *)parser didFindStartTag:(WEBBCodeTag *)tag;
- (void)parser:(WEBBCodeParser *)parser didFindEndTag:(NSString *)tagName;
- (void)parser:(WEBBCodeParser *)parser didFindText:(NSString *)text;
- (void)parserDidFindLineBreak:(WEBBCodeParser *)parser;

@end

@interface WEBBCodeParser : NSObject

@property (nonatomic, weak) id <WEBBCodeParserDelegate> delegate;

//Defaults to '\'
@property (nonatomic, assign) unichar escapeChar;

//Defaults to UTF-8
@property (nonatomic, assign) NSStringEncoding encoding;

//Call before parsing when reusing the parser. (is called automatically upon initial use.
- (void)reset;

- (WEBBCodeParserStatus)parseData:(NSData *)data error:(NSError **)error;
- (WEBBCodeParserStatus)parseBytes:(void*)bytes withLength:(NSUInteger)bytesLength error:(NSError **)error;
- (WEBBCodeParserStatus)parseString:(NSString *)inputString error:(NSError **)error;

@end