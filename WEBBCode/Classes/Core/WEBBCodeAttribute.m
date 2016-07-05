//
//  WEBBCodeAttribute.m
//  Pods
//
//  Created by Werner Altewischer on 04/07/16.
//
//

#import <WEBBCode/WEBBCodeAttribute.h>
#import <WEBBCode/WEBBCodeTag.h>

@implementation WEBBCodeAttribute

NSString * const WEBBCodeDefaultAttributeName = @"__default";

+ (instancetype)attributeWithName:(NSString *)name value:(NSString *)value {
    return [[self alloc] initWithName:name value:value];
}

- (instancetype)initWithName:(NSString *)name value:(NSString *)value {
    if ((self = [self init])) {
        _name = name;
        _value = value;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    WEBBCodeAttribute *ret = [self.class attributeWithName:self.name value:self.value];
    return ret;
}

- (BOOL)isDefault {
    return [self.name isEqual:WEBBCodeDefaultAttributeName];
}

@end
