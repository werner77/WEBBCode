//
//  WEBBCodeAttributes.h
//  Pods
//
//  Created by Werner Altewischer on 04/07/16.
//
//

#import <Foundation/Foundation.h>
#import "WEBBCodeAttribute.h"

/**
 * Class which acts as a container for multiple WEBBCodeAttribute instances as contained in a tag.
 *
 * This class is backed by a dictionary to speed up lookup by name. The order of the attributes is maintained.
 */
@interface WEBBCodeAttributes : NSObject<NSCopying>

/**
 * The attributes
 */
@property(nonatomic, readonly) NSArray <WEBBCodeAttribute *> *attributes;

- (instancetype)initWithAttributes:(NSArray <WEBBCodeAttribute *> *)attributes;

+ (instancetype)attributesWithAttributesArray:(NSArray <WEBBCodeAttribute *> *)attributes;

/**
 * Looks up the attribute by the specified name, or nil if it doesn't exist
 */
- (WEBBCodeAttribute *)attributeForName:(NSString *)name;

/**
 * Returns the string value for the specified attribute name, or nil if it doesn't exist.
 */
- (NSString *)attributeValueForName:(NSString *)name;

@end
