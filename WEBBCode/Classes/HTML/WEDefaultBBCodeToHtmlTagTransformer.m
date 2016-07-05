//
// Created by Werner Altewischer on 04/07/16.
//

#import "WEDefaultBBCodeToHtmlTagTransformer.h"
#import "WEBBCodeCommonDefinitions.h"
#import "WEBBCodeToHtmlTagsTransformationDescriptor.h"
#import "WEBBCodeTag.h"
#import "WEBBCodeAttributes.h"

@implementation WEDefaultBBCodeToHtmlTagTransformer {

}

//See: http://www.bbcode.org/reference.php
+ (NSDictionary *)tagTransformationDictionary {
    static NSDictionary *ret = nil;
    WE_DISPATCH_ONCE((^{
            ret = @{
                    @"b" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"strong"],
                    @"i" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"em"],
                    @"u" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"ins"],
                    @"s" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"del"],
                    @"url" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"a" withDefaultAttributeName:@"href"],
                    @"img" : [[WEBBCodeToHtmlTagsTransformationDescriptor descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
                        NSMutableArray *attributes = [NSMutableArray new];

                        NSString *url = tag.content;
                        if (url.length > 0) {
                            WEBBCodeAttribute *sourceAttribute = [WEBBCodeAttribute attributeWithName:@"source" value:url];
                            [attributes addObject:sourceAttribute];
                        }

                        for (WEBBCodeAttribute *sourceAttribute in tag.attributes.attributes) {
                            if (sourceAttribute.isDefault) {
                                //Format: widthxheight
                                NSArray *components = [sourceAttribute.value componentsSeparatedByString:@"x"];
                                if (components.count == 2) {
                                    WEBBCodeAttribute *widthAttribute = [WEBBCodeAttribute attributeWithName:@"width" value:components[0]];
                                    WEBBCodeAttribute *heightAttribute = [WEBBCodeAttribute attributeWithName:@"height" value:components[1]];
                                    [attributes addObject:widthAttribute];
                                    [attributes addObject:heightAttribute];
                                }
                            } else {
                                [attributes addObject:sourceAttribute];
                            }
                        }
                        return @[[WEBBCodeTag tagWithTagName:@"img" attributes:[WEBBCodeAttributes attributesWithAttributesArray:attributes]]];
                    }] withBufferTagContent:YES],
                    @"quote" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByTranslatingTagNameToTagNames:@[@"blockquote", @"p"]],
                    @"code" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"pre"],
                    @"style" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
                        NSDictionary *styleDict = @{@"size" : @"font-size", @"color" : @"color"};
                        NSMutableArray *attributes = [NSMutableArray new];
                        NSMutableString *styleString = [NSMutableString new];
                        for (WEBBCodeAttribute *sourceAttribute in tag.attributes.attributes) {
                            NSString *styleVar = styleDict[sourceAttribute.name];
                            if (styleVar != nil) {
                                [styleString appendFormat:@"%@: %@;", styleVar, sourceAttribute.value];
                            }
                        }
                        if (styleString.length > 0) {
                            [attributes addObject:[WEBBCodeAttribute attributeWithName:@"style" value:styleString]];
                        }
                        return @[[WEBBCodeTag tagWithTagName:@"span" attributes:[WEBBCodeAttributes attributesWithAttributesArray:attributes]]];
                    }],
                    @"color" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
                        NSMutableArray *attributes = [NSMutableArray new];
                        for (WEBBCodeAttribute *sourceAttribute in tag.attributes.attributes) {
                            if (sourceAttribute.isDefault) {
                                //Default attribute translates to style
                                [attributes addObject:[WEBBCodeAttribute attributeWithName:@"style" value:[NSString stringWithFormat:@"color:%@;", sourceAttribute.value]]];
                            } else {
                                //NO support for other attributes yet
                            }
                        }
                        return @[[WEBBCodeTag tagWithTagName:@"span" attributes:[WEBBCodeAttributes attributesWithAttributesArray:attributes]]];
                    }],
                    @"size" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
                        NSMutableArray *attributes = [NSMutableArray new];
                        for (WEBBCodeAttribute *sourceAttribute in tag.attributes.attributes) {
                            if (sourceAttribute.isDefault) {
                                //Default attribute translates to style
                                [attributes addObject:[WEBBCodeAttribute attributeWithName:@"style" value:[NSString stringWithFormat:@"font-size:%@;", sourceAttribute.value]]];
                            } else {
                                //NO support for other attributes yet
                            }
                        }
                        return @[[WEBBCodeTag tagWithTagName:@"span" attributes:[WEBBCodeAttributes attributesWithAttributesArray:attributes]]];
                    }],
                    @"list" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"ul"],
                    @"ul" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"ol" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"li" : [[WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes] withIgnoreLineBreakAfterTag:YES],
                    @"*" : [[[WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"li"] withCloseTagOnLineBreak:YES] withIgnoreLineBreakAfterTag:YES],
                    @"table" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"tr" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"th" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"td" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"center" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"left" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"right" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"justify" : [WEBBCodeToHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes]
            };
    }));
    return ret;
}

/**
 * Returns the HTML tag(s) for the supplied BBCode attribute.
 */
- (NSArray <WEBBCodeTag *> *)htmlTagsForTag:(WEBBCodeTag *)tag {
    WEBBCodeToHtmlTagsTransformationDescriptor *descriptor = [self transformationDescriptorForTag:tag.tagName];
    return [descriptor htmlTagsForTag:tag];
}

/**
 * Whether or not the specified tag should be closed with its HTML counterpart upon encountering a linebreak.
 *
 * This could be true for example for the tag [*] within bulleted lists.
 */
- (BOOL)shouldCloseTagForLineBreak:(NSString *)tag {
    BOOL ret = NO;
    WEBBCodeToHtmlTagsTransformationDescriptor *descriptor = [self transformationDescriptorForTag:tag];

    if (descriptor) {
        ret = descriptor.closeTagOnLineBreak;
    }
    return ret;
}

- (BOOL)shouldIgnoreLineBreakAfterTag:(NSString *)tag {
    BOOL ret = NO;
    WEBBCodeToHtmlTagsTransformationDescriptor *descriptor = [self transformationDescriptorForTag:tag];

    if (descriptor) {
        ret = descriptor.ignoreLineBreakAfterTag;
    }
    return ret;
}

- (WEBBCodeToHtmlTagsTransformationDescriptor *)transformationDescriptorForTag:(NSString *)tagName {
    return [self.class tagTransformationDictionary][tagName];
}

- (BOOL)shouldBufferContentForTag:(NSString *)tag {
    BOOL ret = NO;
    WEBBCodeToHtmlTagsTransformationDescriptor *descriptor = [self transformationDescriptorForTag:tag];
    if (descriptor) {
        ret = descriptor.bufferTagContent;
    }
    return ret;
}

@end