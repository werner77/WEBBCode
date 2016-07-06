//
// Created by Werner Altewischer on 04/07/16.
//

#import "WEBBCodeHtmlCopyTagTransformer.h"
#import "WEBBCodeAttribute.h"
#import "WEBBCodeCommonDefinitions.h"


@implementation WEBBCodeHtmlCopyTagTransformer {

}

/**
 * Returns the HTML tag(s) for the supplied BBCode attribute.
 */
- (NSArray <WEBBCodeTag *> *)htmlTagsForTag:(WEBBCodeTag *)tag {
    return tag == nil ? nil : @[tag];
}

/**
 * Whether or not the specified tag should be closed with its HTML counterpart upon encountering a linebreak.
 *
 * This could be true for example for the tag [*] within bulleted lists.
 */
- (BOOL)shouldCloseTagForLineBreak:(NSString *)tag {
    return NO;
}

- (BOOL)shouldBufferContentForTag:(NSString *)tag {
    return NO;
}

- (BOOL)shouldIgnoreLineBreakAfterTag:(NSString *)tag {
    return NO;
}

@end