//
//  CRMainWindows.h
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CRBrains.h"
#import "CRPopup.h"
#import "CRMouseOverTextView.h"
#import "CRMainWindowsDelegate.h"
#import "CRBookView.h"
#import "NSUserDefaults (MoreTypes).h"
#import "CRStatus.h"
#import "CRColoursAndAttributes.h"
#import "CRDictSearch.h"
#import "CRURLParser.h"
#import "CRAddWords.h"


@interface CRMainWindows : NSWindowController <NSTextDelegate, NSTextViewDelegate, NSAlertDelegate, NSTabViewDelegate> {
	
	CRBrains *brains;
	CRPopup *popup;
    CRDictionary *dictionary;
    IBOutlet CRColoursAndAttributes *coloursAts;
	
	NSNotificationCenter *center;
	NSUserDefaults *settings;
	
	//main window views
    IBOutlet NSScrollView *articleViewScrollView;
	IBOutlet CRMouseOverTextView *articleView;
	IBOutlet CRBookView *bookView;
	
	//main window
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTabView *tabView;
    IBOutlet NSToolbar *toolbar;
	IBOutlet NSToolbarItem *addVocab;
    
    //Summary
    IBOutlet NSButton *summaryAddToSkritterButton;
    
    //drawer
    IBOutlet NSDrawer *drawer;
	
	//Skritter parser
	IBOutlet NSWindow *skritParserWindow;
	IBOutlet NSTextView *skritView;
	IBOutlet NSProgressIndicator *parserSpinny;
	
	//Preferences & vocab parser
	IBOutlet NSWindow *preferences;
	IBOutlet NSWindow *vocabParser;
	
	//Misc
	NSTextStorage *articleStorage;
	NSDictionary *textVocabDictPlusRanges;
	NSArray *summaryArray;
	
    BOOL checkingText;
	BOOL textChanged;
}

@property (strong) NSTextStorage *articleStorage;
@property (assign) BOOL textChanged;
@property (assign) BOOL checkingText;

@property (strong) NSDictionary *textVocabDictPlusRanges;
@property (strong) NSArray *summaryArray;

//Initialisation
-(void)initialisePopup;
-(void)initialiseNotifications;
-(void)setupTextViews;
-(void)updateUseWithSkritterSetting:(NSNotification *)notification;
-(void)useWithSkritterAlert:(NSNotification *)notification;

//Exiting
-(void)appWillTerminate:(NSNotification *)notification;

//Actions
-(IBAction)showEditor:(id)sender;
-(IBAction)showBook:(id)sender;
-(IBAction)showSummary:(id)sender;
-(IBAction)newDocument:(id)sender;
-(IBAction)showSkritterParser:(id)sender;
-(IBAction)showDrawer:(id)sender;
-(IBAction)showSaveAndLoad:(id)sender;
-(IBAction)showBookmarks:(id)sender;

-(IBAction)addSelectedWordToSkritter:(id)sender;

//Delegates
-(void)textViewDidScroll:(NSNotification *)notification;

//Notifications
-(void)loadSettings:(NSNotification *)notification;
-(void)articleViewWantsPopup:(NSNotification *)notification;
-(void)resized:(NSNotification *)notification;
-(void)showSection:(NSNotification *)notification;

//Fonts and layout
-(void)changeFontSizeTo:(CGFloat)someAmount;
-(NSFont *)currentViewFont;
-(void)setFontStuff;
-(void)setFontColour;
-(void)setEditorMargin;
-(void)setLineSpace;

//Skritter Parser Window
-(IBAction)parseSkritList:(id)sender;
-(IBAction)closeWindow:(id)sender;
-(void)parserSpin:(BOOL)yesorno;
-(void)updateSkritterParserView:(NSNotification *)notification;
-(void)skritterParserDone:(NSNotification *)notification;
-(void)skritterParserDoneWithError:(NSNotification *)notification;

//Article parser
-(IBAction)checkText:(id)sender;
-(void)articleParserDone:(NSNotification *)notification;

//Other stuff
-(void)spin:(BOOL)yesorno;

+(NSAttributedString *)articleAtString;

@end
