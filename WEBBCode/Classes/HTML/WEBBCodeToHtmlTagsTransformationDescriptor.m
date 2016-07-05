//
// Created by Werner Altewischer on 04/07/16.
//

#import "WEBBCodeToHtmlTagsTransformationDescriptor.h"
#import "WEBBCodeAttributes.h"
#import "WEBBCodeTag.h"


@implementation WEBBCodeToHtmlTagsTransformationDescriptor {

}

+ (instancetype)descriptorByCopyingTagsAndAttributes {
    return [self descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
        return @[tag];
    }];
}

+ (instancetype)descriptorByTranslatingTagNameTo:(NSString *)htmlTagName {
    return [self descriptorWithTransformationBlock:^NSArray *(WEBBCodeTag *tag) {
        WEBBCodeTag *ret = [tag copy];
        ret.tagName = htmlTagName;
        return @[ret];
    }];
}

+ (instancetype)descriptorByTranslatingTagNameTo:(NSString *)htmlTagName withDefaultAttributeName:(NSString *)defaultAttributeName {
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
    WEBBCodeToHtmlTagsTransformationDescriptor *descriptor = [self new];
    descriptor.transformationBlock = transformationBlock;
    return descriptor;
}

- (instancetype)withCloseTagOnLineBreak:(BOOL)closeTagOnLineBreak {
    self.closeTagOnLineBreak = closeTagOnLineBreak;
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