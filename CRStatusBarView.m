//
//  CRStatusBarView.m
//  Chinese Reader
//
//  Created by Peter on 25/08/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRStatusBarView.h"

@implementation CRStatusBarView

- (void)drawRect:(CGRect)rect
{
    [[NSColor windowBackgroundColor] set];
    NSRectFill([self bounds]);
    
    [[NSColor windowFrameColor] set];
    NSRect line = NSMakeRect(0,0, [self bounds].size.width, 1);
    NSRectFill(line);
    
}

@end
