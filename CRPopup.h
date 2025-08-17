//
//  CRPopup.h
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSUserDefaults (MoreTypes).h"
#import "CRAddWords.h"

@interface CRPopup : NSView {
	NSUserDefaults *settings;
    
    NSTimer *timer;
	
	NSString *itemName;
	NSString *definition;
	NSString *knownItem;
	NSString *pinyin;
	
	CGFloat fontLineHeight;
	
	NSFont *popupFont;
	NSFont *popupDefinitionFont;
	
	NSRect totalRect;
    NSRect glyphRect;
	
	NSSize itemSize;
	NSSize definitionSize;
	NSSize pinyinSize;
	NSSize buttonSize;
	NSSize totalSize;
	
	NSPoint startingPoint;
	
	NSMutableDictionary *itemAttributes;
	NSMutableDictionary *pinyinAttributes;
	NSMutableDictionary *definitionAttributes;
	
	NSDictionary *popupInputDictionary;
	
	NSButton *knowButton;
	NSButton *skritterButton;
	
	NSTextView *itemTextView;
	NSTextView *pinyinTextView;
	NSTextView *definitionTextView;
	
	NSNotificationCenter *center;

	int border;
	
	BOOL showingPopup;
	BOOL showButtons;
	BOOL mouseOverPopup;
	BOOL editorColours;
	
}

@property (strong) NSString *itemName;
@property (strong) NSString *definition;
@property (strong) NSString *knownItem;
@property (strong) NSString *pinyin;

@property (assign) CGFloat fontLineHeight;
@property (assign) NSRect glyphRect;

@property (strong) NSFont *popupFont;
@property (strong) NSFont *popupDefinitionFont;

@property (assign) NSPoint startingPoint;

@property (strong) NSMutableDictionary *itemAttributes;
@property (strong) NSMutableDictionary *pinyinAttributes;
@property (strong) NSMutableDictionary *definitionAttributes;

@property (strong) NSButton *knowButton;
@property (strong) NSButton *skritterButton;

@property (assign) int border;

@property (assign) BOOL showButtons;
@property (assign) BOOL showingPopup;
@property (assign) BOOL mouseOverPopup;
@property (assign) BOOL editorColours;

-(void)loadSettings:(NSNotification *)notification;

-(IBAction)knowButtonClicked:(id)sender;
-(IBAction)skritterButtonClicked:(id)sender;

-(void)displayPopupForNotification:(NSNotification *)notification;
-(void)cursorNotOverItem:(NSNotification *)notification;
-(BOOL)mouseOverPopupOrWord;
-(void)updateBounds:(NSNotification *)notification;
-(void)killPopup:(NSNotification *)notification;

-(void)setupPopup;
-(void)showPopup:(BOOL)yesOrNo;

-(void)inEditor:(NSNotification *)notification;
-(void)inBook:(NSNotification *)notification;


//setup
-(void)setupCurrentFont;
-(void)setupAttributes;
-(void)setupRectSize;
-(void)setupButtons;
-(void)setupTextViews;
-(void)removePopupStuff;

@end
