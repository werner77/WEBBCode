//
//  WEBBCodeAttributes.h
//  Pods
//
//  Created by Werner Altewischer on 04/07/16.
//
//

#import <Foundation/Foundation.h>
#import "WEBBCodeAttribute.h"

@interface WEBBCodeAttributes : NSObject<NSCopying>

@property(nonatomic, readonly) NSArray <WEBBCodeAttribute *> *attributes;

- (instancetype)initWithAttributes:(NSArray <WEBBCodeAttribute *> *)attributes;

+ (instancetype)attributesWithAttributesArray:(NSArray <WEBBCodeAttribute *> *)attributes;

- (WEBBCodeAttribute *)attributeForName:(NSString *)name;
- (NSString *)attributeValueForName:(NSString *)name;

@end
