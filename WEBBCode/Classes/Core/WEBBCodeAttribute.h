//
//  WEBBCodeAttribute.h
//  Pods
//
//  Created by Werner Altewischer on 04/07/16.
//
//

#import <Foundation/Foundation.h>

/**
 * Class describing an attribute (name-value pair).
 *
 * Can be used both for HTML and BBCode.
 *
 * Example: [url href="http://somedomain.com"] when the attribute named href contains the value "http://somedomain.com"
 */
@interface WEBBCodeAttribute : NSObject<NSCopying>

extern NSString * const WEBBCodeDefaultAttributeName;

+ (instancetype)attributeWithName:(NSString *)name value:(NSString *)value;
- (instancetype)initWithName:(NSString *)name value:(NSString *)value;

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *value;

/**
 * Whether the name is equal to the WEBBCodeDefaultAttributeName constant. If so this attribute corresponds to the value
 * of the default attribute.
 *
 * Example: [url=http://somedomain.com]. Here http://somedomain.com corresponds to the default attribute.
 */
- (BOOL)isDefault;

@end
