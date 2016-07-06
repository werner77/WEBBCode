//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>
#import "WEBBCodeHtmlTagTransformer.h"

/**
 * Copies the WEBBCodeHtmlTagTransformer implementation which just copies the BBTags as is.
 *
 * This is mainly useful for testing.
 */
@interface WEBBCodeHtmlCopyTagTransformer : NSObject<WEBBCodeHtmlTagTransformer>
@end