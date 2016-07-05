//
//  WEBBCodeAttribute.h
//  Pods
//
//  Created by Werner Altewischer on 04/07/16.
//
//

#import <Foundation/Foundation.h>

@interface WEBBCodeAttribute : NSObject<NSCopying>

extern NSString * const WEBBCodeDefaultAttributeName;

+ (instancetype)attributeWithName:(NSString *)name value:(NSString *)value;
- (instancetype)initWithName:(NSString *)name value:(NSString *)value;

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *value;

- (BOOL)isDefault;

@end
