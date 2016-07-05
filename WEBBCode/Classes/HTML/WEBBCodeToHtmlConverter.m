//
// Created by Werner Altewischer on 04/07/16.
//

#import "WEBBCodeToHtmlConverter.h"
#import "WEBBCodeToHtmlTagTransformer.h"
#import "WEBBCodeTag.h"

@interface WEBBCodeTagStackItem : NSObject

@property (nonatomic, strong) NSArray<NSString *> *htmlTags;
@property (nonatomic, strong) NSString *bbCodeTag;

@end


@implementation WEBBCodeTagStackItem

@end

@implementation WEBBCodeToHtmlConverter {
    NSMutableString *_output;
    BOOL _paragraphActive;
    NSMutableArray *_tagStack;
}

static NSString * const kHtmlParagraphTag = @"p";

- (instancetype)init {
    if ((self = [super init])) {
    }
    return self;
}

- (NSString *)htmlFromBBCode:(NSString *)bbCode error:(NSError **)error {
    WEBBCodeParser *parser = [WEBBCodeParser new];
    parser.delegate = self;
    _paragraphActive = NO;
    _output = [NSMutableString new];
    _tagStack = [NSMutableArray new];
    if ([parser parseData:[bbCode dataUsingEncoding:parser.encoding] error:error] == WEBBCodeParserStatusError) {
        return nil;
    } else {
        [self popAllTags];
        return _output;
    }
}

#pragma mark - WEBBCodeParserDelegate

- (void)parser:(WEBBCodeParser *)parser didFindStartTag:(WEBBCodeTag *)bbCodeTag {
    NSArray<WEBBCodeTag *> *htmlTags = [self htmlTagsForTag:bbCodeTag];
    [self pushHtmlTags:htmlTags forBBCodeTag:bbCodeTag.tagName];
}

- (void)parser:(WEBBCodeParser *)parser didFindEndTag:(NSString *)tag {
    [self popTagsUpToAndIncluding:tag];
}

- (void)parser:(WEBBCodeParser *)parser didFindText:(NSString *)text {
    [self startParagraphIfNeeded];
    [_output appendString:text];
}

- (void)parserDidFindLineBreak:(WEBBCodeParser *)parser {
    if ([self shouldCloseTagForLineBreak:[self currentBBCodeTag]]) {
        [self popTag];
    } else if (![self endParagraphIfPossible]) {
        [_output appendString:@"<br />\n"];
    }
}

#pragma mark - Protected

- (NSArray *)htmlTagsForTag:(WEBBCodeTag *)tag {
    return [self.transformer htmlTagsForTag:tag];
}

- (BOOL)shouldCloseTagForLineBreak:(NSString *)tag {
    return [self.transformer shouldCloseTagForLineBreak:tag];
}

#pragma mark - Private

- (NSString *)escapedValue:(NSString *)value {
    return [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

- (BOOL)startParagraphIfNeeded {
    BOOL ret = NO;
    if ([self currentHtmlTag] == nil && !_paragraphActive) {
        WEBBCodeTag *paragraphTag = [WEBBCodeTag tagWithTagName:kHtmlParagraphTag attributes:nil];
        [self pushHtmlTags:@[paragraphTag] forBBCodeTag:nil];
        _paragraphActive = YES;
        ret = YES;
    }
    return ret;
}

- (BOOL)endParagraphIfPossible {
    BOOL ret = NO;
    if (_paragraphActive && [[self currentHtmlTag] isEqual:kHtmlParagraphTag]) {
        [self popTag];
        _paragraphActive = NO;
        ret = YES;
    }
    return ret;
}

- (NSString *)currentHtmlTag {
    WEBBCodeTagStackItem *tag = [_tagStack lastObject];
    return tag.htmlTags.lastObject;
}

- (NSString *)currentBBCodeTag {
    WEBBCodeTagStackItem *tag = [_tagStack lastObject];
    return tag.bbCodeTag;
}

- (void)pushHtmlTags:(NSArray<WEBBCodeTag *> *)htmlTags forBBCodeTag:(NSString *)bbCodeTag {

    NSMutableArray *htmlTagNames = [NSMutableArray new];
    for (WEBBCodeTag *htmlTag in htmlTags) {
        [htmlTagNames addObject:htmlTag.tagName];
        [_output appendFormat:@"<%@", htmlTag.tagName];
        for (WEBBCodeAttribute *htmlAttribute in htmlTag.attributes.attributes) {
            NSString *attributeName = htmlAttribute.name;
            NSString *attributeValue = htmlAttribute.value;
            if (attributeName != nil && attributeValue != nil) {
                [_output appendString:@" "];
                [_output appendString:attributeName];
                [_output appendFormat:@"=\"%@\"", [self escapedValue:attributeValue]];
            }
        }
        [_output appendString:@">"];
    }

    WEBBCodeTagStackItem *tag = [WEBBCodeTagStackItem new];
    tag.htmlTags = htmlTagNames;
    tag.bbCodeTag = bbCodeTag;
    [_tagStack addObject:tag];
}

- (WEBBCodeTagStackItem *)popTag {
    WEBBCodeTagStackItem *ret = [_tagStack lastObject];
    [_tagStack removeLastObject];

    if (ret.htmlTags.count > 0) {
        for (NSInteger i = ret.htmlTags.count - 1; i >= 0; i--) {
            NSString *htmlTagName = ret.htmlTags[(NSUInteger)i];
            [_output appendFormat:@"</%@>", htmlTagName];
        }
    }
    return ret;
}

- (WEBBCodeTagStackItem *)popTagsUpToAndIncluding:(NSString *)bbTagName {
    WEBBCodeTagStackItem *ret = nil;
    if ([self stackContainsBBCodeTag:bbTagName]) {
        while (![bbTagName isEqual:self.currentBBCodeTag]) {
            [self popTag];
        }
        if ([bbTagName isEqual:self.currentBBCodeTag]) {
            ret = [self popTag];
        }
    }
    return ret;
}

- (void)popAllTags {
    while (_tagStack.count > 0) {
        [self popTag];
    }
}

- (BOOL)stackContainsBBCodeTag:(NSString *)bbCodeTag {
    if (_tagStack.count > 0) {
        for (NSInteger i = _tagStack.count - 1; i >= 0; i--) {
            WEBBCodeTagStackItem *item = _tagStack[(NSUInteger)i];
            if ([item.bbCodeTag isEqual:bbCodeTag]) {
                return YES;
            }
        }
    }
    return NO;
}

@end