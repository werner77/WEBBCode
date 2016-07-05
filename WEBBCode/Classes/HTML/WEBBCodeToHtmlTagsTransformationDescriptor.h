//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>

@class WEBBCodeAttributes;
@class WEBBCodeTag;

typedef NSArray<WEBBCodeTag *>* (^WEBBCodeTagToHtmlTagsTransformationBlock)(WEBBCodeTag* tag);

@interface WEBBCodeToHtmlTagsTransformationDescriptor : NSObject

@property (nonatomic, copy) WEBBCodeTagToHtmlTagsTransformationBlock transformationBlock;
@property (nonatomic, assign) BOOL closeTagOnLineBreak;

+ (instancetype)descriptorByCopyingTagsAndAttributes;

+ (instancetype)descriptorByTranslatingTagNameTo:(NSString *)htmlTagName;

+ (instancetype)descriptorByTranslatingTagNameTo:(NSString *)htmlTagName withDefaultAttributeName:(NSString *)defaultAttributeName;

+ (instancetype)descriptorByTranslatingTagNameTo:(NSString *)htmlTagName withAttributeNameTranslationDictionary:(NSDictionary *)attributeNameTranslationDictionary;

+ (instancetype)descriptorWithTransformationBlock:(WEBBCodeTagToHtmlTagsTransformationBlock)transformationBlock;

- (instancetype)withCloseTagOnLineBreak:(BOOL)closeTagOnLineBreak;

- (NSArray<WEBBCodeTag *>*)htmlTagsForTag:(WEBBCodeTag *)tag;


@end