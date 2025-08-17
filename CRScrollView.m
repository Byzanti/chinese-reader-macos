//
//  CRScrollView.m
//  Chinese Reader
//
//  Created by Peter Wood on 03/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRScrollView.h"

@implementation CRScrollView

-(void)mouseDown:(NSEvent *)theEvent {
    if (![CRStatus addingBookmark]) { [super mouseDown:theEvent]; return; }
    
    [CRStatus setAddingBookmark:NO];
    [[NSCursor IBeamCursor] set];
}

@end
