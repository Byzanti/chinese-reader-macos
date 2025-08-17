//
//  CRBookViewController.h
//  Chinese Reader
//
//  Created by Peter on 20/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CRMouseOverTextView.h"
#import "CRBookView.h"


@interface CRBookViewController : NSObject {
	
	NSNotificationCenter *center;
    NSUserDefaults *settings;
	
	IBOutlet CRMouseOverTextView *articleView;
	IBOutlet CRBookView *bookView;
	
	IBOutlet NSTextField *bookPositionLabel;
	
	NSTextStorage *bookTextStorage;
	NSLayoutManager *bookLayoutManager;
	
	NSMutableAttributedString *articleString;
	NSAttributedString *articleStringPortion;
	
	int articleStringLocation;
	int articleStringLength;
	
	CRMouseOverTextView *leftColumnTextView;
	CRMouseOverTextView *rightColumnTextView;
	
	NSRect bookViewBounds;
	NSRect leftColumnRect;
	NSRect rightColumnRect;
	NSRect bookRect;
	
	NSButton *forwardButton;
	NSButton *backwardsButton;
}

@property (strong) CRMouseOverTextView *leftColumnTextView;
@property (strong) CRMouseOverTextView *rightColumnTextView;

@property (strong) NSTextStorage *bookTextStorage;

@property (assign) NSRect bookViewBounds;
@property (assign) NSRect leftColumnRect;
@property (assign) NSRect rightColumnRect;

@property (strong) NSMutableAttributedString *articleString;
@property (strong) NSAttributedString *articleStringPortion;
@property (assign) int articleStringLocation;
@property (assign) int articleStringLength;

//Setup
-(void)setupTextViews;
-(void)updateBookRectPosition:(NSNotification *)notification;
-(void)updateRectPositions;
-(void)setBookRect:(NSRect)rect;
-(NSRect)bookRect;


//Text updating
-(void)updateText;
-(void)updatePlaceInText;
-(void)updatePlaceInTextFromNotification:(NSNotification *)notification;
-(void)resetTextPosition:(NSNotification *)notification;

//Text updating (colours)



-(IBAction)goForwards:(id)sender;
-(IBAction)goBackwards:(id)sender;
-(void)updatePositionLabel;

-(NSRange)getViewableRange:(NSTextView *)tv;

@end
