//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>
#import "WEBBCodeHtmlTagTransformer.h"

/**
 * Default BBCode to HTML transformer which implements the tags as specified by:
 *
 * http://www.bbcode.org/reference.php
 *
 * and
 *
 * https://en.wikipedia.org/wiki/BBCode
 */
@interface WEBBCodeHtmlDefaultTagTransformer : NSObject<WEBBCodeHtmlTagTransformer>
@end