//
// Created by Werner Altewischer on 05/07/16.
// Copyright (c) 2016 Werner Altewischer. All rights reserved.
//

#import "WEBBCodeTest.h"


@implementation WEBBCodeTest {

}

- (NSString *)readFromFile:(NSString *)fileName {
    NSString *inputFilePath= [[NSBundle bundleForClass:self.class] pathForResource:fileName ofType:@"txt"];
    XCTAssertNotNil(inputFilePath, @"Expected file to exist");
    NSString *input = [[NSString alloc] initWithContentsOfFile:inputFilePath encoding:NSUTF8StringEncoding error:NULL];
    XCTAssertNotNil(input, @"Expected file to be readable");
    return input;
}

@end