//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>
#import "WEBBCodeParser.h"

@protocol WEBBCodeToHtmlTagTransformer;

@interface WEBBCodeToHtmlConverter : NSObject<WEBBCodeParserDelegate>

@property (nonatomic, strong) id <WEBBCodeToHtmlTagTransformer>transformer;

@property (nonatomic, assign) BOOL useParagraphs;

/**
 * Constructs an HTML string from the supplied BBCodeString.
 */
- (NSString *)htmlFromBBCode:(NSString *)bbCode error:(NSError **)error;

@end
