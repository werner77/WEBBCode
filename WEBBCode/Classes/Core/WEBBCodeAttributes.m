//
//  WEBBCodeAttributes.m
//  Pods
//
//  Created by Werner Altewischer on 04/07/16.
//
//

#import <WEBBCode/WEBBCodeAttributes.h>

@implementation WEBBCodeAttributes {
    NSMutableDictionary *_lookupDictionary;
}

+ (instancetype)attributesWithAttributesArray:(NSArray <WEBBCodeAttribute *> *)attributes {
    return [[self alloc] initWithAttributes:attributes];
}

- (instancetype)initWithAttributes:(NSArray <WEBBCodeAttribute *> *)attributes {
    if ((self = [self init])) {
        _attributes = attributes;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NSMutableArray *copiedAttributes = [[NSMutableArray alloc] initWithCapacity:self.attributes.count];
    for (WEBBCodeAttribute *attr in self.attributes) {
        [copiedAttributes addObject:[attr copy]];
    }
    return [(WEBBCodeAttributes *)[[self class] alloc] initWithAttributes:copiedAttributes];
}

- (NSDictionary *)lookupDictionary {
    if (_lookupDictionary == nil) {
        _lookupDictionary = [NSMutableDictionary new];
        for (WEBBCodeAttribute *attr in self.attributes) {
            if (attr.name != nil && attr.value != nil) {
                _lookupDictionary[attr.name] = attr.value;
            }
        }
    }
    return _lookupDictionary;
}

- (WEBBCodeAttribute *)attributeForName:(NSString *)name {
    return [self.lookupDictionary objectForKey:name];
}

- (NSString *)attributeValueForName:(NSString *)name {
    return [[self attributeForName:name] value];
}

@end
