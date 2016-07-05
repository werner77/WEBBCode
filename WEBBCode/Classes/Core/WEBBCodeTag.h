//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>

@class WEBBCodeAttributes;

/**
 * Class describing a tag, both in BBCode and HTML.
 *
 * Example: [img width="100" height="200"]http://somedomain.com[/img]
 *
 * tagname="img"
 * attributes={"width"="100","height"="200"}
 * content="http://somedomain.com"
 */
@interface WEBBCodeTag : NSObject<NSCopying>

/**
 * The name of the tag.
 */
@property (nonatomic, strong) NSString *tagName;

/**
 * The attributes of the tag.
 */
@property (nonatomic, strong) WEBBCodeAttributes *attributes;

/**
 * The text content of the tag.
 */
@property (nonatomic, strong) NSString *content;

- (instancetype)initWithTagName:(NSString *)tagName attributes:(WEBBCodeAttributes *)attributes;
+ (instancetype)tagWithTagName:(NSString *)tagName attributes:(WEBBCodeAttributes *)attributes;

@end