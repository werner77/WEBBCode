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

/**
 * Code parser return values
 *
 * @see [WEBBCodeParser parseData:error:]
 */
typedef NS_ENUM(NSUInteger, WEBBCodeParserStatus) {
    WEBBCodeParserStatusNone = 0,  //!< No status
    WEBBCodeParserStatusOK = 1, //!< Parsed OK
    WEBBCodeParserStatusInsufficientData = 2, //!< There was insufficient data
    WEBBCodeParserStatusError = 3 //!< Parser errored
};

/**
 * Delegate for the WEBBCodeParser to handle the tags and characters that it encounters.
 */
@protocol WEBBCodeParserDelegate<NSObject>

/**
 * Called when a start tag has been fully parsed.
 *
 * The tag contains the name and attributes.
 *
 * Example: [url href="http://somedomain"]: tagname="url", attributes={"href" = "http://somedomain"}
 */
- (void)parser:(WEBBCodeParser *)parser didFindStartTag:(WEBBCodeTag *)tag;

/**
 * Called when an end tag has been parsed.
 *
 * Example: [/url]: tagname="url"
 */
- (void)parser:(WEBBCodeParser *)parser didFindEndTag:(NSString *)tagName;

/**
 * Called when any text which is not a linebreak or a tag has been parsed.
 */
- (void)parser:(WEBBCodeParser *)parser didFindText:(NSString *)text;

/**
 * Called when a linebreak has been parsed: "\n"
 */
- (void)parserDidFindLineBreak:(WEBBCodeParser *)parser;

@end

@interface WEBBCodeParser : NSObject

/**
 * The delegate
 */
@property (nonatomic, weak) id <WEBBCodeParserDelegate> delegate;

/**
 * Character used for escaping text, defaults to '\' (backslash).
 */
@property (nonatomic, assign) unichar escapeChar;

/**
 * Character encoding to use to interpret the supplied data to the parser.
 *
 * Defaults to UTF-8
 */
@property (nonatomic, assign) NSStringEncoding encoding;

/**
 * Should be called before parsing when reusing the parser.
 *
 * This is called automatically upon initial use.
 */
- (void)reset;

/**
 * Parses the supplied data.
 * The data should be chopped at valid character byte sequence boundaries (not splitting a character sequence, e.g. in UTF-8).
 *
 * The status returned by this method may indicate an error. In that case the supplied error object (if not nil) is filled.
 */
- (WEBBCodeParserStatus)parseData:(NSData *)data error:(NSError **)error;

/**
 * Parses the supplied byte array with the specified length.
 *
 * @see [WEBBCodeParser parseData:error:]
 */
- (WEBBCodeParserStatus)parseBytes:(const void*)bytes withLength:(NSUInteger)bytesLength error:(NSError **)error;

/**
 * Parses the supplied string.
 *
 * @see [WEBBCodeParser parseData:error:]
 */
- (WEBBCodeParserStatus)parseString:(NSString *)inputString error:(NSError **)error;

@end