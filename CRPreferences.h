//
//  CRPreferences.h
//  Chinese Reader
//
//  Created by Peter on 24/05/2012.
//  Copyright 2012 Byzanti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSUserDefaults (MoreTypes).h"
#import "LTKeyPressTableView.h"
#import "CRColoursAndAttributes.h"

@interface CRPreferences : NSWindowController <NSTableViewDataSource, LTKeyPressTableViewDelegate, NSWindowDelegate> {
	NSNotificationCenter *center;
	NSUserDefaults *settings;
    
    IBOutlet CRColoursAndAttributes *coloursAts;
	
	NSMutableArray *knownItemsArrayWithPinyinAndDefinitions;
	
	IBOutlet NSWindow *prefWindow;
	IBOutlet NSTabView *prefTabView;
    IBOutlet NSToolbar *prefToolbar;
	
	//General
	IBOutlet NSMatrix *popupRadioGroup;
	IBOutlet NSMatrix *skritterRadioGroup;
    IBOutlet NSMatrix *programLaunchRadioGroup;
    IBOutlet NSMatrix *addToSkritterRadioGroup;
	
	//Colours
	IBOutlet NSColorWell *editorKnownVocabCW;
	IBOutlet NSColorWell *editorUnknownVocabCW;
    IBOutlet NSColorWell *editorBookmarkCW;
	IBOutlet NSColorWell *editorBackgroundCW;
    IBOutlet NSColorWell *bookKnownVocabCW;
    IBOutlet NSColorWell *bookUnknownVocabCW;
    IBOutlet NSColorWell *bookBookmarkCW;
	IBOutlet NSColorWell *popupCharactersCW;
	IBOutlet NSColorWell *popupPinyinCW;
	IBOutlet NSColorWell *popupDefinitionCW;
	IBOutlet NSColorWell *popupBackgroundEditorCW;
	IBOutlet NSColorWell *popupBackgroundBookCW;
	IBOutlet NSColorWell *popupBorderCW;
	
	IBOutlet NSTextView *articleView;
	IBOutlet NSTextView *outputView;
	
	//Known items
	IBOutlet NSTableView *knownWordsTable;
	BOOL gotNewKnownWords;
	
	//WordAndChar Parser
	IBOutlet NSWindow *wordAndCharacterParserWindow;
	IBOutlet NSTextView *wordAndCharacterParserView;
	IBOutlet NSProgressIndicator *wordAndCharacterParserSpin;
}

@property (strong) NSMutableArray *knownItemsArrayWithPinyinAndDefinitions;
@property (assign) BOOL gotNewKnownWords;

-(IBAction)showGeneralSettings:(id)sender;
-(IBAction)showColourSettings:(id)sender;
-(IBAction)showKnownVocab:(id)sender;
-(IBAction)closeWindow:(id)sender;
-(void)openKnownItems:(NSNotification *)notification;
- (void)resizeWindowForContentSize:(NSSize)size;

//General
-(void)updateGeneralSettings;
-(IBAction)programLaunchRadioClick:(id)sender;
-(IBAction)popupRadioClick:(id)sender;
-(IBAction)skritterRadioClick:(id)sender;
-(IBAction)addToSkritterRadioClick:(id)sender;
-(IBAction)resetSettings:(id)sender;

//Colours
-(void)setupColourWells;
-(IBAction)editorKnownVocabColourChange:(id)sender;
-(IBAction)editorUnknownVocabColourChange:(id)sender;
-(IBAction)editorBackgroundColourChange:(id)sender;
-(IBAction)editorBookmarkColourChange:(id)sender;
-(IBAction)bookKnownVocabColourChange:(id)sender;
-(IBAction)bookUnknownVocabColourChange:(id)sender;
-(IBAction)bookBookmarkColourChange:(id)sender;
-(IBAction)popupCharactersColourChange:(id)sender;
-(IBAction)popupPinyinColourChange:(id)sender;
-(IBAction)popupDefinitionColourChange:(id)sender;
-(IBAction)popupBackgroundEditorColourChange:(id)sender;
-(IBAction)popupBackgroundBookColourChange:(id)sender;
-(IBAction)popupBorderColourChange:(id)sender;

//Known items
-(void)knownItemsDict:(NSNotification *)notification;
-(void)removeKnownItem:(NSArray *)array;
-(IBAction)removeSelection:(id)sender;

//WordAndCharParser
-(IBAction)showWordAndCharacterParser:(id)sender;
-(IBAction)closeWordAndCharacterParserWindow:(id)sender;
-(IBAction)addVocab:(id)sender;
-(void)knownItemsAdded:(NSNotification *)notification;
-(void)spin:(BOOL)yesorno;
	


@end
