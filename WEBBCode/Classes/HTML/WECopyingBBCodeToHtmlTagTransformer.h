//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>
#import "WEBBCodeToHtmlTagTransformer.h"

/**
 * Copies the WEBBCodeToHtmlTagTransformer implementation which just copies the BBTags as is.
 *
 * This is mainly useful for testing.
 */
@interface WECopyingBBCodeToHtmlTagTransformer : NSObject<WEBBCodeToHtmlTagTransformer>
@end