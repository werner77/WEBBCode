//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>
#import "WEBBCodeParser.h"

@protocol WEBBCodeToHtmlTagTransformer;

@interface WEBBCodeToHtmlConverter : NSObject<WEBBCodeParserDelegate>

@property (nonatomic, strong) id <WEBBCodeToHtmlTagTransformer>transformer;

/**
 * Constructs an HTML string from the supplied BBCodeString.
 */
- (NSString *)htmlFromBBCode:(NSString *)bbCode;

@end
