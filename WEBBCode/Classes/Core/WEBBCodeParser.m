//
//  WEBBCodeParser.m
//  WEBBCodeParser
//
//  Created by Werner Altewischer on 03/07/16.
//  Copyright (c) 2016 Werner IT Consultancy. All rights reserved.
//

#import "WEBBCodeParser.h"
#import "WEBBCodeCommonDefinitions.h"
#import "WEBBCodeTag.h"

typedef NS_OPTIONS(NSUInteger, BBCodeStatus) {
    BBCodeStatusNone = 0,
    BBCodeStatusEscaped = 1 << 0,
    BBCodeStatusInTag = 1 << 1,
    BBCodeStatusInClosingTag = 1 << 2,
    BBCodeStatusInAttributeKey = 1 << 3,
    BBCodeStatusInAttributeValue = 1 << 4
};

@implementation WEBBCodeParser {
    BBCodeStatus _status;
    unichar *_buffer;
    NSUInteger _bufferPos;
    NSUInteger _bufferLength;
    NSMutableArray<WEBBCodeAttribute *> *_attributes;
    NSString *_currentTagName;
    NSString *_currentAttributeKey;
    unichar _currentQuoteChar;
}

static const unichar kDefaultEscapeChar = '\\';

#define PUSH_BUFFER(b) { NSAssert(_bufferPos < _bufferLength, @"Buffer pos should always be < bufferLength"); _buffer[_bufferPos++] = b; }

+ (NSCharacterSet *)whitespaceSet{
    static NSCharacterSet *whitespaceSet = nil;
    WE_DISPATCH_ONCE(^{
        whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    });
    return whitespaceSet;
}

+ (NSCharacterSet *)lineBreakSet{
    static NSCharacterSet *lineBreakSet = nil;
    WE_DISPATCH_ONCE(^{
        lineBreakSet = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    });
    return lineBreakSet;
}

+ (NSCharacterSet *)ignoreSet{
    static NSCharacterSet *ignoreSet = nil;
    WE_DISPATCH_ONCE(^{
        ignoreSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\f"];
    });
    return ignoreSet;
}

- (instancetype)init {
    if ((self = [super init])) {
        self.escapeChar = kDefaultEscapeChar;
        self.encoding = NSUTF8StringEncoding;
        [self reset];
    }
    return self;
}

- (void)dealloc {
    [self freeBuffer];
}

- (WEBBCodeParserStatus)parseData:(NSData *)data error:(NSError **)error {
    return [self parseBytes:data.bytes withLength:data.length error:error];
}

- (void)allocateMemoryForBufferIfNeededForLength:(NSUInteger)maxLength {
    NSAssert(_bufferLength >= _bufferPos, @"Buffer length should always be >= _bufferPos");
    NSUInteger currentBufferSpace = _bufferLength - _bufferPos;
    if (maxLength > currentBufferSpace) {
        NSUInteger delta = (maxLength - currentBufferSpace);
        _bufferLength += MAX(_bufferLength, delta);
        _buffer = realloc(_buffer, _bufferLength * sizeof(unichar));
    }
}

- (WEBBCodeParserStatus)parseString:(NSString *)inputString error:(NSError **)error {
    NSUInteger length = inputString.length;

    const unichar escapeChar = self.escapeChar;
    const NSCharacterSet *whitespaceCharacterSet = [[self class] whitespaceSet];
    const NSCharacterSet *lineBreakSet = [[self class] lineBreakSet];

    NSUInteger allocationLength = length;
    if (WE_CONTAINS_BIT(_status, BBCodeStatusEscaped)) {
        allocationLength++;
    }
    [self allocateMemoryForBufferIfNeededForLength:allocationLength];

    for (NSUInteger i = 0; i < length; i++) {
        unichar b = [inputString characterAtIndex:i];

        BOOL ignoreChar = NO;
        BOOL escaped = WE_CONTAINS_BIT(_status, BBCodeStatusEscaped);
        BOOL tagActive = WE_CONTAINS_BIT(_status, BBCodeStatusInTag);
        BOOL inClosingTag = WE_CONTAINS_BIT(_status, BBCodeStatusInClosingTag);
        BOOL inStartTag = tagActive && !inClosingTag;
        BOOL inAttributeKey = WE_CONTAINS_BIT(_status, BBCodeStatusInAttributeKey);
        BOOL inAttributeValue = WE_CONTAINS_BIT(_status, BBCodeStatusInAttributeValue);

        if ([[[self class] ignoreSet] characterIsMember:b]) {
            ignoreChar = YES;
        } else if (escaped) {
            BOOL isEscapableChar = (b == '[' || b == ']' || b == escapeChar || b == _currentQuoteChar);
            if (!isEscapableChar) {
                //Print escape char anyway, which was ignored the previous turn
                PUSH_BUFFER(escapeChar)
            }
            WE_UNSET_BIT(_status, BBCodeStatusEscaped);
        } else if (b == escapeChar) {
            ignoreChar = YES;
            WE_SET_BIT(_status, BBCodeStatusEscaped);
        } else {
            //Check for opening/closing of tags
            if (b == '[' && !tagActive) {

                [self didFindChars];
                ignoreChar = YES;

                //Tag begins
                WE_SET_BIT(_status, BBCodeStatusInTag);
            } else if (b == ']' && tagActive) {
                if (inClosingTag) {
                    [self didCloseTag];
                } else {
                    [self didOpenTag];
                }
                ignoreChar = YES;
            } else if (b == '/' && tagActive && _bufferPos == 0) {
                WE_SET_BIT(_status, BBCodeStatusInClosingTag);
                ignoreChar = YES;
            } else if ([whitespaceCharacterSet characterIsMember:(unichar)b]) {
                if (tagActive) {
                    if (inAttributeValue) {
                        if (_currentQuoteChar == '\0') {
                            if (_bufferPos > 0) {
                                //End of attribute value by whitespace
                                [self finishCurrentAttribute];
                            }
                            ignoreChar = YES;
                        }
                    } else {
                        if (_currentTagName == nil) {
                            NSString *s = [self popStringFromBuffer];
                            _currentTagName = s.length == 0 ? nil : s;
                        }

                        //Ignore whitespaces within tags
                        ignoreChar = YES;

                        if (inStartTag && _currentTagName != nil && !inAttributeKey) {
                            //Start of an attribute
                            WE_SET_BIT(_status, BBCodeStatusInAttributeKey);
                        }
                    }
                } else if ([lineBreakSet characterIsMember:(unichar)b]) {
                    [self didFindChars];
                    [self didFindLineBreak];
                    ignoreChar = YES;
                }
            } else if (b == '=') {
                if (inAttributeKey) {
                    ignoreChar = YES;
                    if (_currentAttributeKey == nil) {
                        _currentAttributeKey = [self popStringFromBuffer];
                    }
                    WE_UNSET_BIT(_status, BBCodeStatusInAttributeKey);
                    WE_SET_BIT(_status, BBCodeStatusInAttributeValue);
                } else if (inStartTag && _currentTagName == nil) {
                    //Default attribute
                    ignoreChar = YES;
                    _currentTagName = [self popStringFromBuffer];
                    WE_SET_BIT(_status, BBCodeStatusInAttributeValue);
                }
            } else if ((b == '\'' || b == '"') && inAttributeValue) {
                if (_currentQuoteChar == '\0') {
                    ignoreChar = YES;
                    _currentQuoteChar = b;
                } else if (_currentQuoteChar == b) {
                    ignoreChar = YES;
                    [self finishCurrentAttribute];
                }
            }
        }

        if (!ignoreChar) {
            PUSH_BUFFER(b)
        }
    }

    WEBBCodeParserStatus status = WEBBCodeParserStatusNone;

    if (WE_CONTAINS_BIT(_status, BBCodeStatusEscaped) || WE_CONTAINS_BIT(_status, BBCodeStatusInTag)) {
        status = WEBBCodeParserStatusInsufficientData;
    } else {
        status = WEBBCodeParserStatusOK;
    }

    if (status == WEBBCodeParserStatusOK && _bufferPos > 0) {
        [self didFindChars];
    }

    //Add support for errors later
    if (error) {
        *error = nil;
    }

    return status;
}

- (WEBBCodeParserStatus)parseBytes:(const void*)bytes withLength:(NSUInteger)bytesLength error:(NSError **)error {
    NSString *bytesAsString = [[NSString alloc] initWithBytesNoCopy:(void *)bytes length:bytesLength encoding:self.encoding freeWhenDone:NO];
    return [self parseString:bytesAsString error:error];
}

- (void)finishCurrentAttribute {
    BOOL defaultAttribute = _currentAttributeKey == nil;
    if (defaultAttribute) {
        _currentAttributeKey = WEBBCodeDefaultAttributeName;
    }
    NSString *attributeValue = [self popStringFromBuffer];
    if (attributeValue != nil && (attributeValue.length > 0 || !defaultAttribute)) {
        WEBBCodeAttribute *attr = [WEBBCodeAttribute attributeWithName:_currentAttributeKey value:attributeValue];
        [_attributes addObject:attr];
    }
    WE_UNSET_BIT(_status, BBCodeStatusInAttributeValue);
    WE_UNSET_BIT(_status, BBCodeStatusInAttributeKey);
    _currentQuoteChar = '\0';
    _currentAttributeKey = nil;
}

- (void)didOpenTag {
    NSString *tagName = nil;
    if (_currentTagName == nil) {
        tagName = [self popStringFromBuffer];
    } else {
        tagName = _currentTagName;
    }
    [self finishCurrentAttribute];

    NSArray *attributes = _attributes;
    if ([self.delegate respondsToSelector:@selector(parser:didFindStartTag:)]) {
        WEBBCodeAttributes *theAttributes = [[WEBBCodeAttributes alloc] initWithAttributes:attributes];
        WEBBCodeTag *theTag = [WEBBCodeTag tagWithTagName:tagName attributes:theAttributes];
        [self.delegate parser:self didFindStartTag:theTag];
    }

    _currentTagName = nil;
    [_attributes removeAllObjects];
    WE_UNSET_BIT(_status, BBCodeStatusInTag);
}

- (void)didCloseTag {
    NSString *text = [self popStringFromBuffer];
    NSString *closeTag = [text stringByTrimmingCharactersInSet:[self.class whitespaceSet]];
    if ([self.delegate respondsToSelector:@selector(parser:didFindEndTag:)]) {
        [self.delegate parser:self didFindEndTag:closeTag];
    }
    WE_UNSET_BIT(_status, BBCodeStatusInTag);
    WE_UNSET_BIT(_status, BBCodeStatusInClosingTag);
}

- (void)didFindChars {
    NSString *text = [self popStringFromBuffer];
    if (text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(parser:didFindText:)]) {
            [self.delegate parser:self didFindText:text];
        }
    }
}

- (void)didFindLineBreak {
    if ([self.delegate respondsToSelector:@selector(parserDidFindLineBreak:)]) {
        [self.delegate parserDidFindLineBreak:self];
    }
}

- (NSString *)popStringFromBuffer {
    NSUInteger length = _bufferPos;
    NSString *ret;
    if (length == 0) {
        ret = @"";
    } else {
        NSUInteger allocationSize = length * sizeof(unichar);
        unichar *dest = malloc(allocationSize);
        memcpy(dest, _buffer, allocationSize);
        ret = [[NSString alloc] initWithCharactersNoCopy:dest length:length freeWhenDone:YES];
        _bufferPos = 0;
    }
    return ret;
}

- (void)reset {
    _bufferPos = 0;
    _bufferLength = 0;
    _currentQuoteChar = '\0';
    _status = BBCodeStatusNone;
    _attributes = [NSMutableArray new];
    [self freeBuffer];
}

- (void)freeBuffer {
    if (_buffer != NULL) {
        free(_buffer);
        _buffer = NULL;
    }
}

@end