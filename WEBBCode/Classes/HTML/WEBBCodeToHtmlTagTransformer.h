//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>

@class WEBBCodeAttribute;
@class WEBBCodeTag;

@protocol WEBBCodeToHtmlTagTransformer <NSObject>

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

@end