//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>

@class WEBBCodeAttributes;

@interface WEBBCodeTag : NSObject<NSCopying>

@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, strong) WEBBCodeAttributes *attributes;

- (instancetype)initWithTagName:(NSString *)tagName attributes:(WEBBCodeAttributes *)attributes;
+ (instancetype)tagWithTagName:(NSString *)tagName attributes:(WEBBCodeAttributes *)attributes;

@end