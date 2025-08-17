//
//  CRBookView.h
//  Chinese Reader
//
//  Created by Peter on 19/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CRMouseOverTextView.h"
#import "CRStatus.h"

@interface CRBookView : NSView {
	
	NSNotificationCenter *center;
	
	id eventMon;
    
    BOOL canScroll;
	
	NSImage *book;
	NSImage *backTexture;
	
	NSRect selfBounds;
	NSRect bookRect;
    
    NSTimer *timer;
}

@property (strong) NSImage *book;
@property (strong) NSImage *backTexture;

@property (assign) NSRect selfBounds;


//Init
-(void)loadImages;

//Other 
-(void)canScroll:(NSTimer *)timer;

-(void)setBookRect;
-(NSRect)bookRect;

//Drawing
- (void)drawTiledInRect:(NSRect)rect origin:(NSPoint)inOrigin operation:(NSCompositingOperation)inOperation;

@end
