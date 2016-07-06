//
// Created by Werner Altewischer on 04/07/16.
//

#import "WEBBCodeHtmlTagsTransformationDescriptor.h"
#import "WEBBCodeAttributes.h"
#import "WEBBCodeTag.h"


@implementation WEBBCodeHtmlTagsTransformationDescriptor {

}

+ (instancetype)descriptorByCopyingTagsAndAttributes {
    return [self descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
        return @[tag];
    }];
}

+ (instancetype)descriptorByCopyingAttributesAndTranslatingTagNameTo:(NSString *)htmlTagName {
    return [self descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
        WEBBCodeTag *ret = [tag copy];
        ret.tagName = htmlTagName;
        return @[ret];
    }];
}

+ (instancetype)descriptorByTranslatingTagNameToTagNames:(NSArray<NSString *>*)tagNames {
    return [self descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
        NSMutableArray *ret = [NSMutableArray new];
        for (NSString *tn in tagNames) {
            WEBBCodeTag *newTag = [[WEBBCodeTag alloc] initWithTagName:tn attributes:nil];
            [ret addObject:newTag];
        }
        return ret;
    }];
}

+ (instancetype)descriptorByCopyingAttributesAndTranslatingTagNameTo:(NSString *)htmlTagName withDefaultAttributeName:(NSString *)defaultAttributeName {
    return [self descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
        WEBBCodeTag *ret = [tag copy];
        ret.tagName = htmlTagName;

        NSMutableArray *newAttributes = [NSMutableArray new];
        for (WEBBCodeAttribute *attribute in tag.attributes.attributes) {
            WEBBCodeAttribute *attributeCopy = attribute;
            if ([attribute isDefault]) {
                if (defaultAttributeName == nil) {
                    attributeCopy = nil;
                } else {
                    attributeCopy = [WEBBCodeAttribute attributeWithName:defaultAttributeName value:attribute.value];
                }
            }
            if (attributeCopy != nil) {
                [newAttributes addObject:attributeCopy];
            }
        }
        ret.attributes = [[WEBBCodeAttributes alloc] initWithAttributes:newAttributes];
        return @[ret];
    }];
}

+ (instancetype)descriptorByTranslatingTagNameTo:(NSString *)htmlTagName withAttributeNameTranslationDictionary:(NSDictionary *)attributeNameTranslationDictionary {
    return [self descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
        WEBBCodeTag *ret = [tag copy];
        ret.tagName = htmlTagName;

        NSMutableArray *newAttributes = [NSMutableArray new];
        for (WEBBCodeAttribute *attribute in tag.attributes.attributes) {
            NSString *newName  = [attributeNameTranslationDictionary objectForKey:attribute.name];
            if (newName != nil) {
                WEBBCodeAttribute *attributeCopy = [WEBBCodeAttribute attributeWithName:newName value:attribute.value];
                [newAttributes addObject:attributeCopy];
            }
        }

        ret.attributes = [[WEBBCodeAttributes alloc] initWithAttributes:newAttributes];
        return @[ret];
    }];
}

+ (instancetype)descriptorWithTransformationBlock:(WEBBCodeTagToHtmlTagsTransformationBlock)transformationBlock {
    WEBBCodeHtmlTagsTransformationDescriptor *descriptor = [self new];
    descriptor.transformationBlock = transformationBlock;
    return descriptor;
}

- (instancetype)withCloseTagOnLineBreak:(BOOL)closeTagOnLineBreak {
    self.closeTagOnLineBreak = closeTagOnLineBreak;
    return self;
}

- (instancetype)withIgnoreLineBreakAfterTag:(BOOL)ignore {
    self.ignoreLineBreakAfterTag = ignore;
    return self;
}

- (instancetype)withBufferTagContent:(BOOL)bufferTagContent {
    self.bufferTagContent = bufferTagContent;
    return self;
}

- (NSArray<WEBBCodeTag *>*)htmlTagsForTag:(WEBBCodeTag *)tag {
    NSArray<WEBBCodeTag *>* ret = nil;
    if (tag != nil && self.transformationBlock != nil) {
        ret = self.transformationBlock(tag);
    }
    return ret;
}

@end