//
//  CRBookView.m
//  Chinese Reader
//
//  Created by Peter on 19/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRBookView.h"
#import "NSImage-Utilities.h"


@implementation CRBookView

@synthesize book;
@synthesize backTexture;

@synthesize selfBounds;

//init

-(void)awakeFromNib {		
	
	center = [NSNotificationCenter defaultCenter];
	
	
	NSEvent * (^monitorHandler)(NSEvent *);
	monitorHandler = ^NSEvent * (NSEvent * theEvent) {
			
		switch ([theEvent keyCode]) {
			case 123:    // Left arrow
				[center postNotificationName:@"GoBackwards" object:self];
				break;
			case 124:    // Right arrow
				[center postNotificationName:@"GoForwards" object:self];
				break;
				default:
				break;
		}
			// Return the event, a new event, or, to stop 
			// the event from being dispatched, nil
			return theEvent;
	};
		
		// Creates an object we do not own, but must keep track
		// of so that it can be "removed" when we're done
	eventMon = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:monitorHandler];
		
	[self loadImages];
	[self setBookRect];
	[self setSelfBounds:[self bounds]];
    
    canScroll = YES;
}

-(void)loadImages {
	[self setBook:[NSImage imageNamed:@"tbook7"]];
	[self setBackTexture:[NSImage imageNamed:@"woodplanks"]];
}

//Other

- (BOOL) acceptsFirstResponder
{
    return YES;
}
- (BOOL) resignFirstResponder
{
    return YES;
}
- (BOOL) becomeFirstResponder
{
    return YES;
}

-(void)scrollWheel:(NSEvent *)event {
    if (!canScroll) return;
    canScroll = NO;
    CGFloat deltaX = [event deltaX];
    if (deltaX < 0) [center postNotificationName:@"GoForwards" object:self];
    if (deltaX > 0) [center postNotificationName:@"GoBackwards" object:self];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(canScroll:) userInfo:nil repeats:NO];
}

-(void)canScroll:(NSTimer *)timer {
    canScroll = YES;
}



-(void)setBookRect {
	bookRect = [book proportionalRectForTargetRect:selfBounds];
}

-(NSRect)bookRect {
	return bookRect;
}

//Drawing
-(void)drawTiledInRect:(NSRect)rect origin:(NSPoint)inOrigin operation:(NSCompositingOperation)inOperation {
	NSGraphicsContext* gc = [NSGraphicsContext currentContext];
	[gc saveGraphicsState];
	
	[gc setPatternPhase:inOrigin];
	
	NSColor* patternColor = [NSColor colorWithPatternImage:[self backTexture]];
	[patternColor set];
	NSRectFillUsingOperation(rect, inOperation);
	
	[gc restoreGraphicsState];
}

-(void)drawRect:(NSRect)dirtyRect {
	selfBounds = [self bounds];
	
	[self lockFocus];
	
	NSPoint patternOrigin = [self convertPoint:NSMakePoint(0.0f, 0.0f) toView:nil];
	[self drawTiledInRect:selfBounds origin:patternOrigin operation:NSCompositeCopy];
	
	[self setBookRect];
    [book drawInRect:[self bookRect] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	[center postNotificationName:@"UpdateBookRectPosition" object:self userInfo:[NSDictionary dictionaryWithObject:NSStringFromRect(bookRect) forKey:@"bookRect"]]; 
	
    [self unlockFocus];
	
}

//Misc

-(void)mouseDown:(NSEvent *)theEvent {
    if (![CRStatus addingBookmark]) { [super mouseDown:theEvent]; return; }
    
    [CRStatus setAddingBookmark:NO];
    [[NSCursor arrowCursor] set];
}



@end
