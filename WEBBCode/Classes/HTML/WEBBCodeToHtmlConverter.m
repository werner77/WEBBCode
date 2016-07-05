//
// Created by Werner Altewischer on 04/07/16.
//

#import "WEBBCodeToHtmlConverter.h"
#import "WEBBCodeToHtmlTagTransformer.h"
#import "WEBBCodeTag.h"
#import "WEBBCodeCommonDefinitions.h"

@interface WEBBCodeTagStackItem : NSObject

@property (nonatomic, strong) NSArray<NSString *> *htmlTags;
@property (nonatomic, strong) WEBBCodeTag *bbCodeTag;

- (void)appendContents:(NSString * )s;
- (NSString *)contents;

@end


@implementation WEBBCodeTagStackItem {
    NSMutableString *_contents;
}

- (void)appendContents:(NSString * )s {
    if (s.length > 0) {
        if (_contents == nil) {
            _contents = [NSMutableString new];
        }
        [_contents appendString:s];
    }
}

- (NSString *)contents {
    return _contents;
}

@end

@implementation WEBBCodeToHtmlConverter {
    NSMutableString *_output;
    BOOL _paragraphActive;
    NSMutableArray *_tagStack;
    WEBBCodeTag *_bufferedTag;
    WEBBCodeTag *_lastClosedTag;
    BOOL _foundTextAfterTagClosure;
}

static NSString * const kHtmlParagraphTag = @"p";

+ (NSCharacterSet *)whitespaceCharacterSet {
    static NSCharacterSet *set = nil;
    WE_DISPATCH_ONCE((^{
        set = [NSCharacterSet whitespaceCharacterSet];
    }));
    return set;
}

- (instancetype)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)reset {
    _output = nil;
    _paragraphActive = NO;
    [_tagStack removeAllObjects];
    _bufferedTag = nil;
    _lastClosedTag = nil;
    _foundTextAfterTagClosure = NO;
}

- (NSString *)htmlFromBBCode:(NSString *)bbCode error:(NSError **)error {
    WEBBCodeParser *parser = [WEBBCodeParser new];
    [self reset];
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
    _foundTextAfterTagClosure = YES;
    NSArray<WEBBCodeTag *> *htmlTags = nil;
    if ([self shouldOutputTextForTag:bbCodeTag.tagName]) {
        if (_bufferedTag == nil) {
            htmlTags = [self htmlTagsForTag:bbCodeTag];
        }
    } else if (_bufferedTag == nil) {
        //Delay the push: buffer the tag contents until the closing tag occurs
        _bufferedTag = bbCodeTag;
    }
    [self pushHtmlTags:htmlTags forBBCodeTag:bbCodeTag];
}

- (void)parser:(WEBBCodeParser *)parser didFindEndTag:(NSString *)tag {
    WEBBCodeTagStackItem *stackItem = [self popTagsUpToAndIncluding:tag];
    if (_bufferedTag == stackItem.bbCodeTag && _bufferedTag != nil) {
        _bufferedTag.content = stackItem.contents;

        NSArray<WEBBCodeTag *> *htmlTags = [self htmlTagsForTag:_bufferedTag];
        [self pushHtmlTags:htmlTags forBBCodeTag:_bufferedTag];
        [self popTagsUpToAndIncluding:tag];

        _bufferedTag = nil;
    }
}

- (void)parser:(WEBBCodeParser *)parser didFindText:(NSString *)text {
    if (_bufferedTag == nil) {
        if ([self startParagraphIfNeeded]) {
            _foundTextAfterTagClosure = YES;
        }
        [_output appendString:text];
        if (!_foundTextAfterTagClosure && [text stringByTrimmingCharactersInSet:[[self class] whitespaceCharacterSet]].length > 0) {
            _foundTextAfterTagClosure = YES;
        }
    } else {
        WEBBCodeTagStackItem *topStackItem = [_tagStack lastObject];
        [topStackItem appendContents:text];
    }
}

- (void)parserDidFindLineBreak:(WEBBCodeParser *)parser {
    if (_bufferedTag == nil) {
        NSString *tag = [self currentBBCodeTag].tagName;
        BOOL canoutputLineBreak = YES;
        if ([self shouldCloseTagForLineBreak:tag]) {
            [self popTag];
            _foundTextAfterTagClosure = NO;
        } else if ([self endParagraphIfPossible]) {
            canoutputLineBreak = NO;
        }
        if (canoutputLineBreak && (_foundTextAfterTagClosure || ![self shouldIgnoreLineBreakAfterTag:_lastClosedTag.tagName])) {
            [_output appendString:@"<br />"];
        }
        [_output appendString:@"\n"];
    }
}

#pragma mark - Protected

- (NSArray *)htmlTagsForTag:(WEBBCodeTag *)tag {
    return [self.transformer htmlTagsForTag:tag];
}

- (BOOL)shouldCloseTagForLineBreak:(NSString *)tag {
    return [self.transformer shouldCloseTagForLineBreak:tag];
}

- (BOOL)shouldIgnoreLineBreakAfterTag:(NSString *)tag {
    return [self.transformer shouldIgnoreLineBreakAfterTag:tag];
}

#pragma mark - Private

- (NSString *)escapedValue:(NSString *)value {
    return [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

- (BOOL)startParagraphIfNeeded {
    BOOL ret = NO;
    if (self.useParagraphs && [self currentHtmlTag] == nil && !_paragraphActive) {
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

- (BOOL)shouldOutputTextForTag:(NSString *)tagName {
    return ![self.transformer shouldBufferContentForTag:tagName];
}

- (NSString *)currentHtmlTag {
    WEBBCodeTagStackItem *tag = [_tagStack lastObject];
    return tag.htmlTags.lastObject;
}

- (WEBBCodeTag *)currentBBCodeTag {
    WEBBCodeTagStackItem *tag = [_tagStack lastObject];
    return tag.bbCodeTag;
}

- (void)pushHtmlTags:(NSArray<WEBBCodeTag *> *)htmlTags forBBCodeTag:(WEBBCodeTag *)bbCodeTag {

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

    _lastClosedTag = ret.bbCodeTag;
    _foundTextAfterTagClosure = NO;

    return ret;
}

- (WEBBCodeTagStackItem *)popTagsUpToAndIncluding:(NSString *)bbTagName {
    WEBBCodeTagStackItem *ret = nil;
    if ([self stackContainsBBCodeTag:bbTagName]) {
        while (![bbTagName isEqual:self.currentBBCodeTag.tagName]) {
            [self popTag];
        }
        if ([bbTagName isEqual:self.currentBBCodeTag.tagName]) {
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
            if ([item.bbCodeTag.tagName isEqual:bbCodeTag]) {
                return YES;
            }
        }
    }
    return NO;
}

@end