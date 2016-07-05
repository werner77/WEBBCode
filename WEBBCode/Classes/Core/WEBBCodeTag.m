//
// Created by Werner Altewischer on 04/07/16.
//

#import <WEBBCode/WEBBCodeTag.h>
#import <WEBBCode/WEBBCodeAttributes.h>


@implementation WEBBCodeTag {

}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(WEBBCodeAttributes *)attributes {
    if ((self = [self init])) {
        _tagName = tagName;
        _attributes = attributes;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[self class] tagWithTagName:_tagName attributes:[_attributes copy]];
}

+ (instancetype)tagWithTagName:(NSString *)tagName attributes:(WEBBCodeAttributes *)attributes {
    return [[self alloc] initWithTagName:tagName attributes:attributes];
}

@end