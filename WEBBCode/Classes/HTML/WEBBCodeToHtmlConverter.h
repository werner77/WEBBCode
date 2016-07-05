//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>
#import <WEBBCode/WEBBCodeParser.h>

@protocol WEBBCodeToHtmlTagTransformer;

/**
 * Class with functionality to convert BBCode to HTML.
 */
@interface WEBBCodeToHtmlConverter : NSObject<WEBBCodeParserDelegate>

/**
 * The transformer to use to translate BBCode tags to HTML tags.
 *
 * @see WEBBCodeToHtmlTagTransformer
 */
@property (nonatomic, strong) id <WEBBCodeToHtmlTagTransformer>transformer;

/**
 * Whether or not to use <p> for paragraphs, default is to use a <br/> whenever a linebreak is encountered.
 */
@property (nonatomic, assign) BOOL useParagraphs;

/**
 * Constructs an HTML string from the supplied BBCodeString.
 */
- (NSString *)htmlFromBBCode:(NSString *)bbCode error:(NSError **)error;

@end
