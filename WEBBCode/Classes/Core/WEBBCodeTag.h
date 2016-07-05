//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>

@class WEBBCodeAttributes;

@interface WEBBCodeTag : NSObject<NSCopying>

@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, strong) WEBBCodeAttributes *attributes;
@property (nonatomic, strong) NSString *content;

- (instancetype)initWithTagName:(NSString *)tagName attributes:(WEBBCodeAttributes *)attributes;
+ (instancetype)tagWithTagName:(NSString *)tagName attributes:(WEBBCodeAttributes *)attributes;

@end