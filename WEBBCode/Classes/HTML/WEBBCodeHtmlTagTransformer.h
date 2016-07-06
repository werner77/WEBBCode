//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>

@class WEBBCodeAttribute;
@class WEBBCodeTag;

@protocol WEBBCodeHtmlTagTransformer <NSObject>

/**
 * Returns the HTML tag(s) for the supplied BBCode attribute.
 */
- (NSArray <WEBBCodeTag *> *)htmlTagsForTag:(WEBBCodeTag *)tag;

/**
 * Whether or not the specified tag should be closed with its HTML counterpart upon encountering a linebreak.
 *
 * This could be true for example for the tag [*] within bulleted lists.
 */
- (BOOL)shouldCloseTagForLineBreak:(NSString *)tag;

/**
 * Whether a linebreak encountered directly after the tag should be ignored.
 *
 * This could be true if the tag inherently results in a linebreak, e.g. for the [li] tag
 */
- (BOOL)shouldIgnoreLineBreakAfterTag:(NSString *)tag;

/**
 * If true, the text content of the tag will not be output but stored in the WEBBCodeTag.content property.
 *
 * This could be true for example for the [img]http://somedomain.com[/img] tag where the content represents an url and should be output as an attribute.
 */
- (BOOL)shouldBufferContentForTag:(NSString *)tag;

@end