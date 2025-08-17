//
//  CRPreferences.m
//  Chinese Reader
//
//  Created by Peter on 24/05/2012.
//  Copyright 2012 Byzanti. All rights reserved.
//

#import "CRPreferences.h"


@implementation CRPreferences
@synthesize knownItemsArrayWithPinyinAndDefinitions;
@synthesize gotNewKnownWords;

-(void)awakeFromNib {
	settings = [NSUserDefaults standardUserDefaults];
	NSToolbar *toolbar = [prefWindow toolbar];
	[toolbar setSelectedItemIdentifier:@"general"];
    [prefTabView selectTabViewItemAtIndex:0];
    [self resizeWindowForContentSize:NSMakeSize(480, 400)];
	
	center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(knownItemsDict:) name:@"KnownItemsDictForPreferences" object:nil];
	[center addObserver:self selector:@selector(knownItemsAdded:) name:@"AddKnownItemsFromArray" object:nil];
    [center addObserver:self selector:@selector(openKnownItems:) name:@"OpenKnownItems" object:nil];
	
	[knownWordsTable setDataSource:self];
    [self updateGeneralSettings];
    
}

-(void)windowDidBecomeMain:(NSNotification *)notification {
    
    //Gets latest updates
    
    [self updateGeneralSettings];
    
    [self setGotNewKnownWords:NO];
	[center postNotificationName:@"WantKnownItemsDictForPreferences" object:self];
}


//Toolbar
-(IBAction)showGeneralSettings:(id)sender {
    [prefTabView selectTabViewItemAtIndex:0];
    [self resizeWindowForContentSize:NSMakeSize(480, 400)];
}

-(IBAction)showColourSettings:(id)sender {
    [self setupColourWells];
    [prefTabView selectTabViewItemAtIndex:1];
    [self resizeWindowForContentSize:NSMakeSize(480, 400)];
}

-(IBAction)showKnownVocab:(id)sender {
    [self setGotNewKnownWords:NO];
	[center postNotificationName:@"WantKnownItemsDictForPreferences" object:self];
	[prefTabView selectTabViewItemAtIndex:2];
    [self resizeWindowForContentSize:NSMakeSize(480, 400)];
}

-(IBAction)closeWindow:(id)sender {
    [prefWindow close];
}

-(void)openKnownItems:(NSNotification *)notification {
    [prefToolbar setSelectedItemIdentifier:@"knownItems"];
    [self resizeWindowForContentSize:NSMakeSize(480, 400)];
    [self showKnownVocab:self];
}

- (void)resizeWindowForContentSize:(NSSize)size { 
    NSRect windowFrame = [NSWindow contentRectForFrameRect:[[self window] frame] styleMask:[[self window] styleMask]]; 
    NSRect newWindowFrame = [NSWindow frameRectForContentRect: NSMakeRect( NSMinX( windowFrame ), NSMaxY( windowFrame ) - size.height, size.width, size.height ) styleMask:[[self window] styleMask]]; 
    [[self window] setFrame:newWindowFrame display:YES animate:[[self window] isVisible]]; 
} 

//General section
-(void)updateGeneralSettings {
    
    //program launch
    if ([settings boolForKey:@"loadLastViewed"]) [programLaunchRadioGroup selectCellWithTag:0];
    else [programLaunchRadioGroup selectCellWithTag:1];
    
    //popup
    if ([settings boolForKey:@"popupForAllWords"]) [popupRadioGroup selectCellWithTag:1];
    else [popupRadioGroup selectCellWithTag:0];
    
    //Skritter
    if ([settings boolForKey:@"useWithSkritter"]) [skritterRadioGroup selectCellWithTag:1];
    else [skritterRadioGroup selectCellWithTag:0];
    
    //Add to Skritter popup button
    if ([settings boolForKey:@"addToSkritterAddsToKnownItems"]) [addToSkritterRadioGroup selectCellWithTag:0];
    else [addToSkritterRadioGroup selectCellWithTag:1];
    
}

-(IBAction)programLaunchRadioClick:(id)sender {
	if ([programLaunchRadioGroup selectedTag] == 1) [settings setBool:NO forKey:@"loadLastViewed"];
	else [settings setBool:YES forKey:@"loadLastViewed"];
	[settings synchronize];
}

-(IBAction)popupRadioClick:(id)sender {
	if ([popupRadioGroup selectedTag] == 1) [settings setBool:YES forKey:@"popupForAllWords"];
	else [settings setBool:NO forKey:@"popupForAllWords"];
	[settings synchronize];
	[center postNotificationName:@"ReloadPopupState" object:self];
}

-(IBAction)skritterRadioClick:(id)sender {
	if ([skritterRadioGroup selectedTag] == 1) [settings setBool:YES forKey:@"useWithSkritter"];
	else [settings setBool:NO forKey:@"useWithSkritter"];
	[settings synchronize];
	[center postNotificationName:@"UpdateUseWithSkritter" object:self];
}

-(IBAction)addToSkritterRadioClick:(id)sender {
	if ([addToSkritterRadioGroup selectedTag] == 1) [settings setBool:NO forKey:@"addToSkritterAddsToKnownItems"];
	else [settings setBool:YES forKey:@"addToSkritterAddsToKnownItems"];
	[settings synchronize];
}


-(IBAction)resetSettings:(id)sender {
	[center postNotificationName:@"ResetSettingsToDefaults" object:self];
	NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setMessageText:@"Settings reset"];
    [alert setInformativeText:@"All settings reset. Your added vocabulary is unaffected. You will however have to check the text again!"];
	[alert runModal];
    
    [settings setBool:NO forKey:@"firstTime"];
    [settings synchronize];
	
	[articleView setTextColor:[settings colorForKey:@"editorKnownVocabColour"]];
	[outputView setTextColor:[settings colorForKey:@"editorKnownVocabColour"]];
	[articleView setBackgroundColor:[settings colorForKey:@"editorBackgroundColour"]];
	[outputView setBackgroundColor:[settings colorForKey:@"editorBackgroundColour"]];
    
    [center postNotificationName:@"ReloadPopupState" object:self];
    [center postNotificationName:@"UpdateUseWithSkritter" object:self];
	
	[popupRadioGroup selectCellWithTag:1];
	[skritterRadioGroup selectCellWithTag:1];
    [programLaunchRadioGroup selectCellWithTag:1];
	[addToSkritterRadioGroup selectCellWithTag:1];
}


//Colours section
-(void)setupColourWells {
	[editorKnownVocabCW setColor:[settings colorForKey:@"editorKnownVocabColour"]];
	[editorUnknownVocabCW setColor:[settings colorForKey:@"editorUnknownVocabColour"]];
	[editorBackgroundCW setColor:[settings colorForKey:@"editorBackgroundColour"]];
    [editorBookmarkCW setColor:[settings colorForKey:@"editorBookmarkColour"]];
    [bookKnownVocabCW setColor:[settings colorForKey:@"bookKnownVocabColour"]];
    [bookUnknownVocabCW setColor:[settings colorForKey:@"bookUnknownVocabColour"]];
    [bookBookmarkCW setColor:[settings colorForKey:@"bookBookmarkColour"]];
	[popupCharactersCW setColor:[settings colorForKey:@"popupCharactersColour"]];
	[popupPinyinCW setColor:[settings colorForKey:@"popupPinyinColour"]];
	[popupDefinitionCW setColor:[settings colorForKey:@"popupDefinitionColour"]];
	[popupBackgroundEditorCW setColor:[settings colorForKey:@"popupBackgroundEditorColour"]];
	[popupBackgroundBookCW setColor:[settings colorForKey:@"popupBackgroundBookColour"]];
	[popupBorderCW setColor:[settings colorForKey:@"popupBorderColour"]];
	
}



-(IBAction)editorKnownVocabColourChange:(id)sender {
	[settings setColor:[editorKnownVocabCW color] forKey:@"editorKnownVocabColour"];
    [settings synchronize];
    [coloursAts recolourKnownItems];

}
-(IBAction)editorUnknownVocabColourChange:(id)sender {
	[settings setColor:[editorUnknownVocabCW color] forKey:@"editorUnknownVocabColour"];
    [settings synchronize];
    [coloursAts recolourUnknownItems];
}
-(IBAction)editorBackgroundColourChange:(id)sender {
	[settings setColor:[editorBackgroundCW color] forKey:@"editorBackgroundColour"];
    [settings synchronize];
	[articleView setBackgroundColor:[editorBackgroundCW color]];
	[outputView setBackgroundColor:[editorBackgroundCW color]];
}
-(IBAction)editorBookmarkColourChange:(id)sender {
	[settings setColor:[editorBookmarkCW color] forKey:@"editorBookmarkColour"];
    [settings synchronize];
    [coloursAts recolourBookmarks];
}
-(IBAction)bookKnownVocabColourChange:(id)sender {
	[settings setColor:[bookKnownVocabCW color] forKey:@"bookKnownVocabColour"];
    [settings synchronize];
    [center postNotificationName:@"UpdateBookText" object:self];

}
-(IBAction)bookUnknownVocabColourChange:(id)sender {
	[settings setColor:[bookUnknownVocabCW color] forKey:@"bookUnknownVocabColour"];
    [settings synchronize];
    [center postNotificationName:@"UpdateBookText" object:self];
}
-(IBAction)bookBookmarkColourChange:(id)sender {
	[settings setColor:[bookBookmarkCW color] forKey:@"bookBookmarkColour"];
    [settings synchronize];
    [center postNotificationName:@"UpdateBookText" object:self];
}
-(IBAction)popupCharactersColourChange:(id)sender {
	[settings setColor:[popupCharactersCW color] forKey:@"popupCharactersColour"];
    [settings synchronize];
}
-(IBAction)popupPinyinColourChange:(id)sender {
	[settings setColor:[popupPinyinCW color] forKey:@"popupPinyinColour"];
    [settings synchronize];
}
-(IBAction)popupDefinitionColourChange:(id)sender {
	[settings setColor:[popupDefinitionCW color] forKey:@"popupDefinitionColour"];
    [settings synchronize];
}
-(IBAction)popupBackgroundEditorColourChange:(id)sender {
	[settings setColor:[popupBackgroundEditorCW	color] forKey:@"popupBackgroundEditorColour"];
    [settings synchronize];
}
-(IBAction)popupBackgroundBookColourChange:(id)sender {
	[settings setColor:[popupBackgroundBookCW color] forKey:@"popupBackgroundBookColour"];
    [settings synchronize];
}
-(IBAction)popupBorderColourChange:(id)sender {
	[settings setColor:[popupBorderCW color] forKey:@"popupBorderColour"];
    [settings synchronize];
}





/////KNOWN WORDS SECTION
//This gets the latest version of the knownItemsArray + pinyin + definitions
-(void)knownItemsDict:(NSNotification *)notification {
	[self setKnownItemsArrayWithPinyinAndDefinitions:[NSMutableArray arrayWithArray:[[notification userInfo] objectForKey:@"array"]]];
	[self setGotNewKnownWords:YES];
	[knownWordsTable reloadData];
	[knownWordsTable display];
}

//Tableview
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {

	
	int numberOfRows = 0;
	
	if (tableView == knownWordsTable && !gotNewKnownWords) numberOfRows = 1;
	else if (tableView == knownWordsTable && gotNewKnownWords) numberOfRows = [knownItemsArrayWithPinyinAndDefinitions count];
	
	return numberOfRows;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

	NSString *itemString = @"";
	
	if (tableView == knownWordsTable && !gotNewKnownWords && [[tableColumn identifier] isEqualToString:@"Characters"]) itemString = @"Loading...";
	
	else if (tableView == knownWordsTable && gotNewKnownWords) {
		
		NSArray *itemArray = [NSArray arrayWithArray:[knownItemsArrayWithPinyinAndDefinitions objectAtIndex:row]];
		
		if ([[tableColumn identifier] isEqualToString:@"Characters"]) itemString = [itemArray objectAtIndex:0];
		if ([[tableColumn identifier] isEqualToString:@"Pinyin"]) itemString = [itemArray objectAtIndex:1];
		if ([[tableColumn identifier] isEqualToString:@"Definition"]) itemString = [itemArray objectAtIndex:2];
		
	}
	
	return itemString;
}

-(void)removeKnownItem:(NSArray *)array {
	[center postNotificationName:@"RemoveKnownItem" object:self userInfo:[NSDictionary dictionaryWithObject:[array objectAtIndex:0] forKey:@"knownItem"]];
	[knownItemsArrayWithPinyinAndDefinitions removeObject:array];
    [knownWordsTable deselectAll:self];
	[knownWordsTable reloadData];
}

//Buttons
-(IBAction)removeSelection:(id)sender {
	NSIndexSet *indexSet = [knownWordsTable selectedRowIndexes];
	int indexCount = [indexSet count];
	if (indexCount == 0) return;
	
	else {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Remove"];
		[alert addButtonWithTitle:@"Cancel"];
		if (indexCount > 1) {
			[alert setMessageText:[NSString stringWithFormat:@"Removing %i items",indexCount]]; 
			[alert setInformativeText:@"Are you sure you want to remove these words?"];
		}
		else {
			[alert setMessageText:@"Removing one item"]; 
			[alert setInformativeText:@"Are you sure you want to remove this word?"];
		}
		[alert setAlertStyle:NSWarningAlertStyle];
		int returnValue = [alert runModal];
		if( returnValue != NSAlertFirstButtonReturn ) return;
		
		NSMutableArray *arrayOfStuffToRemove = [NSMutableArray array];
		NSUInteger index=[indexSet firstIndex];
		
		while (index != NSNotFound) {
			
			[arrayOfStuffToRemove addObject:[knownItemsArrayWithPinyinAndDefinitions objectAtIndex:index]];
			
			index=[indexSet indexGreaterThanIndex:index];
			
		}
		
		for (int i = 0; i < [arrayOfStuffToRemove count]; i++) [self removeKnownItem:[arrayOfStuffToRemove objectAtIndex:i]];
		
	}
}

-(void)deleteSelectionFromTableView:(NSTableView *)tableView {
    [self removeSelection:self];
}

//Word and character parser
-(IBAction)showWordAndCharacterParser:(id)sender {
	[[self window] orderOut:sender];
	if (wordAndCharacterParserWindow) [wordAndCharacterParserWindow makeKeyAndOrderFront:sender];
}

-(IBAction)closeWordAndCharacterParserWindow:(id)sender {
	[wordAndCharacterParserWindow close];
	[[self window] makeKeyAndOrderFront:sender]; 
}
-(IBAction)addVocab:(id)sender {
	
	NSString *addSomeWords = @"Please add some words first.";
	
	if ([[wordAndCharacterParserView string] isEqualToString:@""] || [[wordAndCharacterParserView string] isEqualToString:addSomeWords]) [wordAndCharacterParserView setString:addSomeWords];
	
	[self spin:YES];
	
	NSArray *tempArray = [[wordAndCharacterParserView string] componentsSeparatedByString:@"\n"];
	
	NSMutableArray *arrayWithNewItems = [NSMutableArray array];
	
	for (int i = 0; i < [tempArray count]; i++) {
		
		NSString *object = [tempArray objectAtIndex:i];
		NSRange whitespaceRange = [object rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (whitespaceRange.location == NSNotFound) [arrayWithNewItems addObject:object];
		else [arrayWithNewItems addObject:[object substringToIndex:whitespaceRange.location]];
	}
	
	[center postNotificationName:@"AddKnownItemsFromArray" object:self userInfo:[NSDictionary dictionaryWithObject:arrayWithNewItems forKey:@"array"]];

	
}

-(void)knownItemsAdded:(NSNotification *)notification {
	[self spin:NO];
	[self setGotNewKnownWords:NO];
	[center postNotificationName:@"WantKnownItemsDictForPreferences" object:self];
	[wordAndCharacterParserView setString:@"Done! Close this window."];
}

-(void)spin:(BOOL)yesorno {
	if (yesorno) {
		[wordAndCharacterParserSpin setHidden:NO];
		[wordAndCharacterParserSpin startAnimation:self];
	}
	else {
		[wordAndCharacterParserSpin stopAnimation:self];
		[wordAndCharacterParserSpin setHidden:YES];
	}
}

@end
