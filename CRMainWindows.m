//
//  CRMainWindows.m
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRMainWindows.h"

CRMainWindows *shared;
NSAttributedString *sharedAtString;

@implementation CRMainWindows
@synthesize articleStorage;
@synthesize checkingText;
@synthesize textChanged;

@synthesize textVocabDictPlusRanges;
@synthesize summaryArray;

//Initialisation
/////////////////////////////////////////////////////////////////
-(void)awakeFromNib {
	
	[self initialiseNotifications];
	
	//settings
	settings = [NSUserDefaults standardUserDefaults];
    
	//brains
	brains = [[CRBrains alloc] init];
	[brains startup];
	
	//Misc
	articleStorage = [articleView textStorage];
    checkingText = NO;
	
	//Popup
	[self initialisePopup];
	
	[self setupTextViews];
	
	toolbar = [mainWindow toolbar];
	[toolbar setSelectedItemIdentifier:@"editor"];
	
	[self updateUseWithSkritterSetting:nil];
	
    [[articleViewScrollView contentView] setPostsBoundsChangedNotifications:YES];
    dictionary = [CRDictionary shared];
	
}

-(void)initialiseNotifications { 
	center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(updateSkritterParserView:) name:@"UpdateSkritterParserView" object:brains];
	[center addObserver:self selector:@selector(skritterParserDone:) name:@"SkritterParserDone" object:brains];
    [center addObserver:self selector:@selector(skritterParserDoneWithError:) name:@"SkritterParserDoneWithError" object:brains];
	[center addObserver:self selector:@selector(articleParserDone:) name:@"ArticleParserDone" object:brains];
	[center addObserver:self selector:@selector(loadSettings:) name:@"LoadSettings" object:nil];
	[center addObserver:self selector:@selector(articleViewWantsPopup:) name:@"WantPopup" object:nil];
	[center addObserver:self selector:@selector(addItemToKnownItems:) name:@"AddToKnownItems" object:popup];
	[center addObserver:self selector:@selector(resized:) name:@"Resized" object:nil];
	[center addObserver:self selector:@selector(updateUseWithSkritterSetting:) name:@"UpdateUseWithSkritter" object:nil];
	[center addObserver:self selector:@selector(useWithSkritterAlert:) name:@"UseWithSkritterAlert" object:nil];
    [center addObserver:self selector:@selector(textViewDidScroll:) name:NSViewBoundsDidChangeNotification object:[articleViewScrollView contentView]];
    [center addObserver:self selector:@selector(appWillTerminate:) name:@"WillTerminate" object:nil];
    [center addObserver:self selector:@selector(loadDictionary) name:@"LoadDictionary" object:nil];
    [center addObserver:self selector:@selector(showSection:) name:@"ShowSection" object:nil];
    [center addObserver:self selector:@selector(setFontStuff) name:@"SetFontStuff" object:nil];
    [center addObserver:self selector:@selector(setLineSpace) name:@"SetLineSpace" object:nil];
    [center addObserver:self selector:@selector(setEditorMargin) name:@"SetEditorMargin" object:nil];
}

-(void)loadDictionary {
    dictionary = [CRDictionary shared];
}

-(void)initialisePopup {
	NSRect tabViewFrame = [tabView frame];
	popup = [[CRPopup alloc] initWithFrame:tabViewFrame];
	[tabView addSubview:popup];
	[popup showPopup:NO];
}

-(void)setupTextViews {
	[articleView setUsesFontPanel:YES];
}

-(void)updateUseWithSkritterSetting:(NSNotification *)notification {
	if ([settings boolForKey:@"useWithSkritter"]) {
		[addVocab setLabel:@"Add Skritter vocab"];
		[addVocab setAction:@selector(showSkritterParser:)];
        [summaryAddToSkritterButton setHidden:NO];
	}
	
	else {
		[addVocab setLabel:@"Add vocab"];
		[addVocab setAction:@selector(showVocabParser:)];
		[summaryAddToSkritterButton setHidden:YES];
	}
	
}

//Alert

-(void)useWithSkritterAlert:(NSNotification *)notification {
	
	NSAlert *alert = [[NSAlert alloc] init]; 
	[alert addButtonWithTitle:@"I have a Skritter account"]; 
	[alert addButtonWithTitle:@"I don't have a Skritter account"]; 
	[alert setMessageText:@"Do you have a Skritter account?"]; 
	[alert setInformativeText:@"If you have a Skritter account, Chinese Reader can be configured to use the vocab you have in Skritter (Skritter is a program that helps you write Chinese)."]; 
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:@"useWithSkritterAlert"];
	
}

-(void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(NSString *)contextInfo {
    if ([contextInfo isEqualToString:@"useWithSkritterAlert"]) {
        NSString *statusText;
       	if (returnCode == NSAlertFirstButtonReturn) {
            [settings setBool:YES forKey:@"useWithSkritter"];
            statusText = @"Step one: add your Skritter vocabulary!";
        }
        else { 
            [settings setBool:NO forKey:@"useWithSkritter"];
            statusText = @"Optional: add a list of vocab you already know";
        }
        NSDictionary *newStatusDict = [NSDictionary dictionaryWithObject:statusText forKey:@"All"];
        [center postNotificationName:@"newStatusText" object:self userInfo:newStatusDict];
        [settings synchronize];
        
        [self updateUseWithSkritterSetting:nil];
        
    }
}

//Exiting

-(void)appWillTerminate:(NSNotification *)notification {

}

//Main window actions
/////////////////////////////////////////////////////////////////

-(IBAction)showEditor:(id)sender {
    [mainWindow makeKeyAndOrderFront:self];
    [toolbar setSelectedItemIdentifier:@"editor"];
	[tabView selectTabViewItemAtIndex:0];
	[popup showPopup:NO];
	
	[mainWindow makeFirstResponder:articleView];
	[articleView setNeedsDisplay:YES];
	
    [CRStatus setAddingBookmark:NO];
    
    [center postNotificationName:@"InEditor" object:self];
	
	
}

-(IBAction)showBook:(id)sender {
	if (textChanged) {
		[center postNotificationName:@"UpdateBookText" object:self];
		[center postNotificationName:@"ResetTextPosition" object:self];
		[self setTextChanged:NO];
	}
	
    [toolbar setSelectedItemIdentifier:@"book"];
	[tabView selectTabViewItemAtIndex:1];
	[popup showPopup:NO];
	
	[mainWindow makeFirstResponder:bookView];
	[bookView setNeedsDisplay:YES];
    
    [CRStatus setAddingBookmark:NO];
    
    [center postNotificationName:@"InBook" object:self];
    
    [mainWindow makeKeyAndOrderFront:self];

}

-(IBAction)showSummary:(id)sender {
    [mainWindow makeKeyAndOrderFront:self];
    [toolbar setSelectedItemIdentifier:@"summary"];
	[tabView selectTabViewItemAtIndex:2];
	[popup showPopup:NO];
    
    [CRStatus setAddingBookmark:NO];

}

-(IBAction)newDocument:(id)sender {
    [mainWindow makeKeyAndOrderFront:self];
    if ([CRStatus textChanged]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"newDoc" forKey:@"response"];
        [center postNotificationName:@"saveDialog" object:self userInfo:dict];
    }
    else [center postNotificationName:@"newDoc" object:self];
}


-(IBAction)showSkritterParser:(id)sender {    
	[[self window] orderOut:sender];
	if (skritParserWindow) [skritParserWindow makeKeyAndOrderFront:sender];
}

-(IBAction)showVocabParser:(id)sender {
	[[self window] orderOut:sender];
	if (preferences) [preferences makeKeyAndOrderFront:sender];
	[center postNotificationName:@"OpenKnownItems" object:self];
    if (vocabParser) [vocabParser makeKeyAndOrderFront:sender];
}

-(IBAction)showDrawer:(id)sender {
    [mainWindow makeKeyAndOrderFront:self];
    if ([drawer state] == 0) { 
        [drawer open];
        [center postNotificationName:@"UpdateSaveLoadIndex" object:self];
    }
    else if ([drawer state] == 2) [drawer close];
}

-(IBAction)showSaveAndLoad:(id)sender {
    [mainWindow makeKeyAndOrderFront:self];
    if ([drawer state] == 0) [self showDrawer:self];
    [center postNotificationName:@"showSaveAndLoad" object:self];
}

-(IBAction)showBookmarks:(id)sender {
    [mainWindow makeKeyAndOrderFront:self];
    if ([drawer state] == 0) [self showDrawer:self];
    [center postNotificationName:@"showBookmarks" object:self];
}

//For the 'check text' action, see article parser section

//Delegates

-(void)textDidChange:(NSNotification *)aNotification {
    if (![settings boolForKey:@"textChanged"]) {
        
        [settings setBool:YES forKey:@"textChanged"];
        
    }
    //Keep this variable, it is so the book knows to update
	[self setTextChanged:YES];
    [center postNotificationName:@"ArticleTextChanged" object:self];
}


- (NSDictionary *)textView:(NSTextView *)textView shouldChangeTypingAttributes:(NSDictionary *)oldTypingAttributes toAttributes:(NSDictionary *)newTypingAttributes {
    NSFont *myFont = [NSFont fontWithName:[settings objectForKey:@"fontName"] size:[settings floatForKey:@"fontSize"]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[settings colorForKey:@"editorKnownVocabColour"],NSForegroundColorAttributeName,myFont,NSFontAttributeName,[articleView defaultParagraphStyle],NSParagraphStyleAttributeName,nil];
    return attributes;
}


-(void)textViewDidScroll:(NSNotification *)notification {
    [popup showPopup:NO];
}

//Notifications
/////////////////////////////////////

-(void)addItemToKnownItems:(NSNotification *)notification {
	
	NSArray *knownItems = [[notification userInfo] objectForKey:@"items"];
	
    [knownItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //remove attributes from text at location
        [coloursAts removeAttributesForKnownItem:obj];
        [brains addKnownItem:obj];
    }];
    
    //Highlight that the text now needs saved
    [center postNotificationName:@"ArticleTextChanged" object:self];
    [CRStatus setTextChanged:YES];
	
	[center postNotificationName:@"UpdateBookText" object:self];
	
}

-(void)loadSettings:(NSNotification *)notification {

	//fonts
	[self setFontStuff];
    [self setFontColour];
    [coloursAts recolourKnownAndUnknownItems];
    [coloursAts recolourBookmarks];

	//margin
	[self setEditorMargin];
	
	//line spacing
	[self setLineSpace];

	[articleView setBackgroundColor:[settings colorForKey:@"editorBackgroundColour"]];

}

-(void)articleViewWantsPopup:(NSNotification *)notification {
	
	NSMutableDictionary *popupInfoDict = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
	NSString *currentItem = [popupInfoDict objectForKey:@"itemName"];
		
	NSString *itemPinyin = [dictionary pinyinFor:currentItem];
	if (!itemPinyin) return;
	NSString *itemDefinition = [dictionary definitionFor:currentItem];
    if (!itemDefinition) return;
    
	//Adds the pinyin & definition, then sends a message received by CRPopup	
    [popupInfoDict setObject:itemPinyin forKey:@"itemPinyin"];
    [popupInfoDict setObject:itemDefinition forKey:@"itemDefinition"];
    [center postNotificationName:@"GiveMeAPopup" object:self userInfo:popupInfoDict];
  
}

-(void)resized:(NSNotification *)notification {
	[self setEditorMargin];
	
}

-(void)showSection:(NSNotification *)notification {
    NSString *section = [[notification userInfo] objectForKey:@"section"];
    if ([section isEqualToString:@"editor"]) [self showEditor:self];
    if ([section isEqualToString:@"book"]) [self showBook:self];
    if ([section isEqualToString:@"summary"]) [self showSummary:self];
}


//Font and layout ==========================
//========================================================================================================

-(void)changeFontSizeTo:(CGFloat)someAmount {
	NSFont *font = [self currentViewFont];
	
	font = [NSFont fontWithName:[font fontName] size:someAmount];	
	
	[articleView setFont:font];
	
	[settings setFloat:someAmount forKey:@"fontSize"];
}

-(NSFont *)currentViewFont {
    NSFont *font = [NSFont fontWithName:[settings objectForKey:@"fontName"] size:[settings floatForKey:@"fontSize"]];
	return font;
}

-(void)setFontStuff {
	NSFont *font = [NSFont fontWithName:[settings stringForKey:@"fontName"] size:[settings floatForKey:@"fontSize"]];
	if (!font) font= [NSFont systemFontOfSize:14];
	[articleView setFont:font];
	
	[center postNotificationName:@"UpdateBookText" object:self];
}

-(void)setFontColour {
    [articleView setTextColor:[settings colorForKey:@"editorKnownVocabColour"]];
}

-(void)setEditorMargin {
	NSSize articleViewPadding = NSMakeSize(([articleView frame].size.width /100) * [settings floatForKey:@"margin"], 10.0);
	[articleView setTextContainerInset:articleViewPadding];
	
}

-(void)setLineSpace {
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paragraphStyle setLineSpacing:[settings floatForKey:@"lineSpace"]];
	
	[articleStorage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[articleStorage length])];
	
	[articleView setDefaultParagraphStyle:paragraphStyle];
	
	[center postNotificationName:@"UpdateBookText" object:self];

}

//Skritter Parser Window
/////////////////////////////////////

-(IBAction)parseSkritList:(id)sender {
	
	NSString *skritViewString = [skritView string];
	
	//Checks to see if the user has entered anything
	NSString *enterWords = @"Please enter your Skritter vocab. You can find the export tool on the 'My Words' page. \n\nIf you are wanting to use words from outside Skritter, the format is:\nWord/Character(tab)Pinyin(tab)Definition(tab).";
	if ([skritViewString isEqualToString:@""] || [skritViewString isEqualToString:enterWords] || [skritViewString rangeOfString:@"\t"].location == NSNotFound) [skritView setString:enterWords];
	
	//If they have, starts the parser
	else {
		[self parserSpin:YES];
		[brains parseSkritterVocab:skritViewString];
	}
	
}

-(IBAction)closeWindow:(id)sender {
	[skritParserWindow close];
	[[self window] makeKeyAndOrderFront:sender];
}

-(void)updateSkritterParserView:(NSNotification *)notification {
	NSString *message = [[notification userInfo] objectForKey:@"newText"];
	
	if ([message isEqualToString:@"Processing your Skritter vocab...\n"]) [skritView setString:@""];
	
	[skritView insertText:message];
}

-(void)skritterParserDone:(NSNotification *)notification {
	NSDictionary *noteDict = [notification userInfo];
	NSString *done = [noteDict objectForKey:@"doneOK"];
	if ([done isEqualToString:@"YES"]) [skritView insertText:@"\nDone! Close this window and start checking texts!"];
	else [skritView setString:@"\nError. Folder probably read only - check /Library/Application Support/Chinese Reader. Contact author if you cannot resolve the problem."];
	[self parserSpin:NO];
    
    [CRStatus setEditorStatusText:@"Paste text here, then click 'Check text!' to begin"];
    [CRStatus setBookStatusText:@"Paste text into the editor, and click 'Check text!'"];
    [CRStatus setSummaryStatusText:@"Paste text into the editor, and click 'Check text!'"];
}

-(void)skritterParserDoneWithError:(NSNotification *)notification {
    [skritView insertText:@"\nParser stopped owing to error."];
    [self parserSpin:NO];
}

//Article Parser
/////////////////////////////////////

-(IBAction)checkText:(id)sender {
    
    if (checkingText) return;
    checkingText = YES;
    
    [center postNotificationName:@"DeselectSummaryTable" object:self];
    
    NSURL *url = [NSURL URLWithString:[articleView string]];
    if (url && [url host]) {
        [articleStorage setAttributedString:[CRURLParser attributedStringForURL:url]];
        
        return;
    }

	if (![brains skritData]) return; //This might not be doing anything, left in just in case

    
    NSString *articleString = [articleView string];
    
    NSString *helpfulString = @"Paste an article or book in here first!";
    
	if ([articleString isEqualToString:@""] || [articleString isEqualToString:helpfulString]) { 
		[articleView setString:helpfulString]; 
		return; 
	}
	
	[self spin:YES];
    [articleView setEditable:NO];
	[brains parseArticle:articleString];
	
}

-(void)articleParserDone:(NSNotification *)notification {
    
    //NSAttributedString *before = [articleStorage copy];
    
    //Changes the all of the text to the known colour (the next stage just highlights unknown items)
    //It would be better to remove the "unknown item" attribute as well, but no-one will probably notice
    [articleStorage setForegroundColor:[settings colorForKey:@"editorKnownVocabColour"]];

	//Fetches the unknown items arrays
	[self setTextVocabDictPlusRanges:[brains textVocabDictPlusRanges]];
	[self setSummaryArray:[brains summaryArray]];
    
    [center postNotificationName:@"updateSummaryTable" object:self userInfo:[NSDictionary dictionaryWithObject:summaryArray forKey:@"summaryArray"]];
	
	NSArray *unknownWords = [textVocabDictPlusRanges allKeys];
	int unknownWordsCount = [unknownWords count];
    
    //Need to strip out the "Unknown Word" attribute for re-runs.
    [articleStorage removeAttribute:@"Unknown Word" range:NSMakeRange(0, articleStorage.length)];
    
    if (unknownWordsCount > 0) {
        
        //Add attributes to the unknown words
        [articleStorage beginEditing];
        
        [unknownWords enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *rangeArray = [textVocabDictPlusRanges objectForKey:obj];
            [rangeArray enumerateObjectsUsingBlock:^(id objRange, NSUInteger idx, BOOL *stop) {
                [coloursAts addAttributesForUnknownItem:obj atRange:NSRangeFromString(objRange)];
            }];
        }];
        //[articleStorage appendAttributedString:before];
        [articleStorage endEditing];
        
    }
    
    //This line is not needed
    NSAttributedString *afterEdits = [articleStorage copy];
    
	[center postNotificationName:@"UpdateBookText" object:self];
	[self spin:NO];
    [articleView setEditable:YES];
    
    //Highlight that the text now needs saved
    [center postNotificationName:@"ArticleTextChanged" object:self];
    [CRStatus setTextChanged:YES];
    
    NSString *statusText;
    if (unknownWordsCount > 0) statusText = [NSString stringWithFormat:@"%@: unknown items highlighted",[CRStatus currentDocument]];
    else statusText = [NSString stringWithFormat:@"%@: no unknown items!",[CRStatus currentDocument]];
    [CRStatus setEditorStatusText:statusText];
    [CRStatus setBookStatusText:statusText];
    
    checkingText = NO;
    
    //This line is not needed
    sharedAtString = [afterEdits copy];

}


//Other stuff
///////////////////////////////////////////////////////////////////


													 
-(void)spin:(BOOL)yesorno {
	if (yesorno) [center postNotificationName:@"startProgressSpinner" object:self];
	else [center postNotificationName:@"stopProgressSpinner" object:self];
}

-(void)parserSpin:(BOOL)yesorno {
	if (yesorno) {
		[parserSpinny setHidden:NO];
		[parserSpinny startAnimation:self];
	}
	else {
		[parserSpinny stopAnimation:self];
		[parserSpinny setHidden:YES];
	}
}

//This may not return an up to date string; do not use
+(NSAttributedString *)articleAtString {
    return sharedAtString;
}



-(IBAction)addSelectedWordToSkritter:(id)sender {
    
    //If summary view not active throw a message box
    NSString *currentArea = (NSString*)[[tabView selectedTabViewItem] identifier];
    if ([currentArea isEqualToString:@"Summary"]) [CRStatus setSummaryStatusText:@"Please selected text in editor or book mode"];
    
    //Otherwise see if anything is selected
    NSArray *selectedRanges = [articleView selectedRanges];
    if ([selectedRanges count] == 0) {
        [CRStatus setEditorStatusText:@"No text selected"];
        [CRStatus setBookStatusText:@"No text selected"];
        return;
    }
    
    //If so get the strings, and add to an array so they can be added to Skritter
    //At the same time add the words to known words (override on, as often these wont be in the internal dictionary).
    NSMutableArray *knownSelectedWords = [NSMutableArray array];
    NSMutableArray *unknownSelectedWords = [NSMutableArray array];
    [selectedRanges enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *word = [[articleView string] substringWithRange:[obj rangeValue]];
        
        if ([word isEqualToString:@""]) return;
        
        //Remove colouring for unknown items
        [coloursAts removeAttributesForKnownItem:word];
        
        //If it's a known selected word handle differently (this way we can include pinyin and definition right away)
        if ([dictionary itemInDictionary:word]) {
            
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
            [tempDict setObject:word forKey:@"characters"];
            [tempDict setObject:[dictionary pinyinFor:word] forKey:@"pinyin"];
            [tempDict setObject:[dictionary definitionFor:word] forKey:@"definition"];
            
            [knownSelectedWords addObject:[tempDict copy]];
            [brains addKnownItem:word];
        }
        else {
            [unknownSelectedWords addObject:word];
            [brains addKnownItemWithOverride:word];
        }
    }];
    
    //Add words in the array to Skritter (known words - within pinyin and definition)
    if ([knownSelectedWords count] > 0) [CRAddWords addWordsToSkritter:[knownSelectedWords copy]];

    //Add words in the array to Skritter (unknown words)
    if ([unknownSelectedWords count] > 0) [CRAddWords addSelectedWordsToSkritter:[unknownSelectedWords copy]];
    
    //Could add status change here
    [CRStatus setEditorStatusText:[NSString stringWithFormat:@"%lu selected words or characters sent to Skritter",[knownSelectedWords count] + [unknownSelectedWords count]]];
    [CRStatus setBookStatusText:[NSString stringWithFormat:@"%lu selected words or characters sent to Skritter",[knownSelectedWords count] + [unknownSelectedWords count]]];
}


@end






