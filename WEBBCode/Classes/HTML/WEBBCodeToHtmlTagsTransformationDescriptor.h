//
// Created by Werner Altewischer on 04/07/16.
//

#import <Foundation/Foundation.h>

@class WEBBCodeAttributes;
@class WEBBCodeTag;

typedef NSArray<WEBBCodeTag *>* (^WEBBCodeTagToHtmlTagsTransformationBlock)(WEBBCodeTag* tag);

/**
 * Descriptor for describing the transformation of a BBCodeTag into one or more HTML tags.
 */
@interface WEBBCodeToHtmlTagsTransformationDescriptor : NSObject

/**
 * The transformation block, which is used to generate the HTML tags from their BBCode counterpart.
 */
@property (nonatomic, copy) WEBBCodeTagToHtmlTagsTransformationBlock transformationBlock;

/**
 * Whether or not to close the active tag when a line break occurs.
 *
 * Example: for [*] this should be true.
 */
@property (nonatomic, assign) BOOL closeTagOnLineBreak;

/**
 * Whether or not to avoid outputting the tag content but buffering it in the WEBBCodeTag.content property instead.
 *
 * Example: for [img]http://somedomain.com[/img] this would be true, because it should be translated to <img src="http://somedomain.com"></img>
 */
@property (nonatomic, assign) BOOL bufferTagContent;

/**
 * Whether or not a linebreak directly after the tag should be ignored (not translated into a <br/>).
 *
 * Example: for [/li] this would be true because it translates to </li> (list item) (for [*] this is also true, because it also generates a </li> on linebreak).
 */
@property (nonatomic, assign) BOOL ignoreLineBreakAfterTag;


/**
 * Convenience constructor which just copies the tags and attributes into the HTML counterpart using the same name for both tags and attributes.
 */
+ (instancetype)descriptorByCopyingTagsAndAttributes;

/**
 * Convenience constructor which just copies the attributes into the HTML counterpart but substitutes a different tag name.
 */
+ (instancetype)descriptorByCopyingAttributesAndTranslatingTagNameTo:(NSString *)htmlTagName;

/**
 * Convenience constructor which translates a tag into multiple tag names. Attributes are ignored.
 */
+ (instancetype)descriptorByTranslatingTagNameToTagNames:(NSArray<NSString *>*)tagNames;

/**
 * Convenience constructor which translates a tag into a different tagname. copies the attributes as is and specifies a default attribute name to use.
 */
+ (instancetype)descriptorByCopyingAttributesAndTranslatingTagNameTo:(NSString *)htmlTagName withDefaultAttributeName:(NSString *)defaultAttributeName;

/**
 * Convenience constructor which translates a tag into a different tag and uses the supplied dictionary to transform the attributes into differently named attributes (or omit them if no entry exists).
 */
+ (instancetype)descriptorByTranslatingTagNameTo:(NSString *)htmlTagName withAttributeNameTranslationDictionary:(NSDictionary *)attributeNameTranslationDictionary;

/**
 * Most generic constructor which allows for a free form transformation block which generates the HTML tags.
 */
+ (instancetype)descriptorWithTransformationBlock:(WEBBCodeTagToHtmlTagsTransformationBlock)transformationBlock;

/**
 * Factory convenience method which sets the closeTagOnLineBreak property.
 */
- (instancetype)withCloseTagOnLineBreak:(BOOL)closeTagOnLineBreak;

/**
 * Factory convenience method which sets the bufferTagContent property.
 */
- (instancetype)withBufferTagContent:(BOOL)bufferTagContent;

/**
 * Factory convenience method which sets the ignoreLineBreakAfterTag property.
 */
- (instancetype)withIgnoreLineBreakAfterTag:(BOOL)ignore;

/**
 * Method which generates the html tags from the supplied BBCode tag.
 */
- (NSArray<WEBBCodeTag *>*)htmlTagsForTag:(WEBBCodeTag *)tag;


@end