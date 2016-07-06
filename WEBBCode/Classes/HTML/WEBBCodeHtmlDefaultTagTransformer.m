//
// Created by Werner Altewischer on 04/07/16.
//

#import "WEBBCodeHtmlDefaultTagTransformer.h"
#import "WEBBCodeCommonDefinitions.h"
#import "WEBBCodeHtmlTagsTransformationDescriptor.h"
#import "WEBBCodeTag.h"
#import "WEBBCodeAttributes.h"

@implementation WEBBCodeHtmlDefaultTagTransformer {

}

//See: http://www.bbcode.org/reference.php
+ (NSDictionary *)tagTransformationDictionary {
    static NSDictionary *ret = nil;
    WE_DISPATCH_ONCE((^{
            ret = @{
                    @"b" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"strong"],
                    @"i" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"em"],
                    @"u" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"ins"],
                    @"s" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"del"],
                    @"url" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"a" withDefaultAttributeName:@"href"],
                    @"img" : [[WEBBCodeHtmlTagsTransformationDescriptor descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
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
                    @"quote" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByTranslatingTagNameToTagNames:@[@"blockquote", @"p"]],
                    @"code" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"pre"],
                    @"style" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
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
                    @"color" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
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
                    @"size" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
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
                    @"list" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"ul"],
                    @"ul" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"ol" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"li" : [[WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes] withIgnoreLineBreakAfterTag:YES],
                    @"*" : [[[WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingAttributesAndTranslatingTagNameTo:@"li"] withCloseTagOnLineBreak:YES] withIgnoreLineBreakAfterTag:YES],
                    @"table" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"tr" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"th" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"td" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"center" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"left" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"right" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes],
                    @"justify" : [WEBBCodeHtmlTagsTransformationDescriptor descriptorByCopyingTagsAndAttributes]
            };
    }));
    return ret;
}

/**
 * Returns the HTML tag(s) for the supplied BBCode attribute.
 */
- (NSArray <WEBBCodeTag *> *)htmlTagsForTag:(WEBBCodeTag *)tag {
    WEBBCodeHtmlTagsTransformationDescriptor *descriptor = [self transformationDescriptorForTag:tag.tagName];
    return [descriptor htmlTagsForTag:tag];
}

/**
 * Whether or not the specified tag should be closed with its HTML counterpart upon encountering a linebreak.
 *
 * This could be true for example for the tag [*] within bulleted lists.
 */
- (BOOL)shouldCloseTagForLineBreak:(NSString *)tag {
    BOOL ret = NO;
    WEBBCodeHtmlTagsTransformationDescriptor *descriptor = [self transformationDescriptorForTag:tag];

    if (descriptor) {
        ret = descriptor.closeTagOnLineBreak;
    }
    return ret;
}

- (BOOL)shouldIgnoreLineBreakAfterTag:(NSString *)tag {
    BOOL ret = NO;
    WEBBCodeHtmlTagsTransformationDescriptor *descriptor = [self transformationDescriptorForTag:tag];

    if (descriptor) {
        ret = descriptor.ignoreLineBreakAfterTag;
    }
    return ret;
}

- (WEBBCodeHtmlTagsTransformationDescriptor *)transformationDescriptorForTag:(NSString *)tagName {
    return [self.class tagTransformationDictionary][tagName];
}

- (BOOL)shouldBufferContentForTag:(NSString *)tag {
    BOOL ret = NO;
    WEBBCodeHtmlTagsTransformationDescriptor *descriptor = [self transformationDescriptorForTag:tag];
    if (descriptor) {
        ret = descriptor.bufferTagContent;
    }
    return ret;
}

@end