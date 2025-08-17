//
//  CRSummary.m
//  Chinese Reader
//
//  Created by Peter Wood on 26/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRSummary.h"

@implementation CRSummary

@synthesize summaryArray;
@synthesize selectedItems;

-(void)awakeFromNib {
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateSummaryTable:) name:@"updateSummaryTable" object:nil];
    [center addObserver:self selector:@selector(deselectSummaryTable:) name:@"DeselectSummaryTable" object:nil];
    [center addObserver:self selector:@selector(loadSummaryArrayFromSave:) name:@"LoadSummaryArray" object:nil];
    [center addObserver:self selector:@selector(clearSummaryTable:) name:@"ClearSummaryTable" object:nil];
    settings = [NSUserDefaults standardUserDefaults];
    
    summaryArray = [NSMutableArray array];
    selectedItems = [NSMutableArray array];
    
    [summaryBarView setHidden:YES];
}

-(void)loadSummaryArrayFromSave:(NSNotification *)notification {
    [self setSummaryArray:[[notification userInfo] objectForKey:@"summaryArray"]];
    [summaryTable reloadData];
}

-(void)clearSummaryTable:(NSNotification *)notification {
    [self setSummaryArray:[NSMutableArray array]];
}

-(void)updateSummaryTable:(NSNotification *)notification {
    [self setSummaryArray:[[notification userInfo] objectForKey:@"summaryArray"]];
    
    NSMutableArray *tableArray = [NSMutableArray array];
    
    frequency = [CRFrequency shared];
    simpTradConversion = [CRSimpTradConversion shared];
    NSString *articleString = [articleView string];
    
    [[self summaryArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *characters = [obj objectAtIndex:0];
        //Simplifies as frequency data is in simplified characters
        NSString *charactersSimplified = [simpTradConversion simplifiedForTraditional:characters];
        NSString *pinyin = [obj objectAtIndex:1];
        NSString *definition = [obj objectAtIndex:2];
        NSString *occurrences = [obj objectAtIndex:3];
        NSString *skritFrequency = [frequency skritFrequencyForString:charactersSimplified];
        NSString *oldHSKFrequency = [frequency oldHSKLevelForString:charactersSimplified];
        NSString *newHSKFrequency = [frequency newHSKLevelForString:charactersSimplified];
        NSAttributedString *textExample = [self textExampleForWord:charactersSimplified inText:articleString];
        NSString *textExampleStringValue = [textExample string]; //This one is here so compare: can be used to sort the attributed string
        
        NSDictionary *lineDict = [NSDictionary dictionaryWithObjectsAndKeys:characters,@"characters",pinyin,@"pinyin",definition,@"definition",
                                  occurrences,@"occurrences",skritFrequency,@"frequency",oldHSKFrequency,@"oldHSKFrequency",
                                  textExample,@"textExample",newHSKFrequency,@"newHSKFrequency",textExampleStringValue,@"textExampleStringValue",nil];
        
        [tableArray addObject:lineDict];
    }];
    
    [self setSummaryArray:tableArray];
    
    
    [summaryTable reloadData];
    
    [self saveSummaryArray];
}

-(NSAttributedString *)textExampleForWord:(NSString *)characters inText:(NSString *)text {
    
    int stringLength = [text length];
    int exampleChars = 10; //this is x before the character, x after
    
    NSRange wordRange = [text rangeOfString:characters];
    
    //Starting location
    int startingLocation = wordRange.location - exampleChars;
    if (startingLocation < 0) startingLocation = 0;
    
    //Endpoint
    int length = wordRange.location - startingLocation + [characters length] + exampleChars;
    if (startingLocation + length > stringLength) length = stringLength - startingLocation;
    
    NSRange exampleRange = NSMakeRange(startingLocation, length);

    NSString *exampleString = [[text substringWithRange:exampleRange] stringByRemovingCharactersInSet:[NSCharacterSet newlineCharacterSet] andString:@"\t"];
    exampleString = [exampleString stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
    exampleString = [exampleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //Highlights word
    NSRange newWordRange = [exampleString rangeOfString:characters];
    NSMutableAttributedString *atExampleString = [[NSMutableAttributedString alloc] initWithString:exampleString];
    [atExampleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:newWordRange];
    
    return [atExampleString copy];
    
}

//Tableview
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = [summaryArray count];
    NSString *summaryString = @"";
    if (count == 1) summaryString = @"There is 1 unknown item in this text";
    if (count > 1) summaryString = [NSString stringWithFormat:@"There are %lu unknown items in this text",count];
    [CRStatus setSummaryStatusText:summaryString];
    
    return count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (![summaryArray objectAtIndex:0]) return @"等一下...";
    NSDictionary *lineDict = [[self summaryArray] objectAtIndex:row];
    
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"Characters"]) return [lineDict objectForKey:@"characters"];
    if ([identifier isEqualToString:@"Pinyin"]) return [lineDict objectForKey:@"pinyin"];
    if ([identifier isEqualToString:@"Definition"]) return [lineDict objectForKey:@"definition"];
    if ([identifier isEqualToString:@"Occurrences"]) return [lineDict objectForKey:@"occurrences"];
    if ([identifier isEqualToString:@"Frequency"]) return [lineDict objectForKey:@"frequency"];
    if ([identifier isEqualToString:@"Old HSK"]) return [lineDict objectForKey:@"oldHSKFrequency"];
    if ([identifier isEqualToString:@"New HSK"]) return [lineDict objectForKey:@"newHSKFrequency"];
    if ([identifier isEqualToString:@"Text example"]) return [lineDict objectForKey:@"textExample"];
    
    return @"error";
}

//Tableview Delgate
- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    [summaryArray sortUsingDescriptors:[summaryTable sortDescriptors]];
    [summaryTable reloadData];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSUInteger number = [summaryTable numberOfSelectedRows];
    if (number == 0) { [self showSummaryBar:NO]; return; }
    
    if ([summaryBarView isHidden]) [self showSummaryBar:YES];
    if (number == 1) {
        [selectedItemsTextField setStringValue:@"1 word selected"];
        [knownItemButton setTitle:@"I know this word"];
    }
    else {
        [selectedItemsTextField setStringValue:[NSString stringWithFormat:@"%lu words selected",number]];
        [knownItemButton setTitle:@"I know these words"];
    }
}

-(void)showSummaryBar:(BOOL)value {
    NSRect bounds = [tabView bounds];
    CGFloat statusBarHeight = [statusBarView bounds].size.height;
    bounds.size.height = bounds.size.height - statusBarHeight;
    
    if (value) {
        [summaryBarView setHidden:NO];
        CGFloat summaryBarViewFrameHeight = [summaryBarView frame].size.height;
        NSRect newFrame = NSMakeRect(0,summaryBarViewFrameHeight,bounds.size.width,bounds.size.height - summaryBarViewFrameHeight);
        [tableScrollView setFrame:newFrame];
    }
    
    else {
        [tableScrollView setFrame:bounds];
        [summaryBarView setHidden:YES];
    }
}

-(NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
    
    if (!row) return nil;
    NSAttributedString *atExampleText = [[summaryArray objectAtIndex:row] objectForKey:@"textExample"];
    return [atExampleText string];

}

- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn {
    //This is pre change
    NSIndexSet *indexSet = [summaryTable selectedRowIndexes];
    NSUInteger index = [indexSet firstIndex];
    [[self selectedItems] removeAllObjects];
    
    while (index != NSNotFound) {
        [[self selectedItems] addObject:[summaryArray objectAtIndex:index]];
        index = [indexSet indexGreaterThanIndex:index];
    }
    
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    //This is post change
    [summaryTable deselectAll:self];
    if ([selectedItems count] == 0) return;
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [indexSet addIndex:[summaryArray indexOfObject:obj]];
    }];
    
    [summaryTable selectRowIndexes:indexSet byExtendingSelection:YES];

}

-(void)copyFromTableView:(NSTableView *)tableView {
    [self copyToClipboard:self];
}

//Other

-(NSArray *)arrayOfSelectedItems {
    NSIndexSet *indexSet = [summaryTable selectedRowIndexes];
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger index=[indexSet firstIndex];
    
    while (index != NSNotFound) {
        [array addObject:[summaryArray objectAtIndex:index]];
        index = [indexSet indexGreaterThanIndex:index];
    }
    
    return [array copy];
}

//Buttons

-(IBAction)addToKnownWords:(id)sender {
    //Gets a list of the selected items    
    NSArray *itemsArray = [self arrayOfSelectedItems];
    
    //Adds items to known words, then removes them from table array
    [itemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [CRAddWords addWordToKnownWords:[obj objectForKey:@"characters"]];
        [summaryArray removeObject:obj];
    }];
    
    [summaryTable deselectAll:self];
    [summaryTable reloadData];
    [self saveSummaryArray];

    [center postNotificationName:@"SaveSummaryAsWordsRemoved" object:self userInfo:nil];
    
    //Highlight that the text now needs saved
    [center postNotificationName:@"ArticleTextChanged" object:self];
    [CRStatus setTextChanged:YES];
    
}

-(IBAction)addToSkritter:(id)sender {

    NSArray *itemsArray = [self arrayOfSelectedItems];
    [CRAddWords addWordsToSkritter:itemsArray];
    
    if ([settings boolForKey:@"addToSkritterAddsToKnownItems"]) [self addToKnownWords:self];
    
}

-(IBAction)copyToClipboard:(id)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Words"];
	[alert addButtonWithTitle:@"Everything"];
	[alert setMessageText:@"What do you want to copy?"];
	[alert setInformativeText:@"For pasting into Skritter or similar applications, copy words only. Otherwise, copy everything in a tab delimited format."];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:@"copyAlert"];
    
}

-(IBAction)goToPlaceInText:(id)sender {
    [center postNotificationName:@"ShowSection" object:self userInfo:[NSDictionary dictionaryWithObject:@"editor" forKey:@"section"]];
    
    NSString *word = [[summaryArray objectAtIndex:[summaryTable selectedRow]] objectForKey:@"characters"];
    highlightRange = [[articleView string] rangeOfString:word];
    [articleView scrollRangeToVisible:highlightRange];

    [[articleView layoutManager] addTemporaryAttribute:NSBackgroundColorAttributeName value:[NSColor greenColor] forCharacterRange:highlightRange];
    
    timerFlash = 0;
    goToTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(highlightWord:) userInfo:nil repeats:YES];
    
}

//Goto timer

-(void)highlightWord:(NSTimer *)timer {
    if (timerFlash == 0) { [self removeHighlightAttribute]; return; }
    if (timerFlash == 1) { [self addHighlightAttribute]; return; }
    if (timerFlash == 2) { [self removeHighlightAttribute]; return; }
    if (timerFlash == 3) { [self addHighlightAttribute]; return; }
    else {
        [self removeHighlightAttribute];
        timerFlash = 0;
        [goToTimer invalidate];
    }
}

-(void)addHighlightAttribute {
    [[articleView layoutManager] addTemporaryAttribute:NSBackgroundColorAttributeName value:[NSColor greenColor] forCharacterRange:highlightRange];
    timerFlash++;
}
-(void)removeHighlightAttribute {
    [[articleView layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:highlightRange];
    timerFlash++;
}


//Alert for copy
-(void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(NSString *)contextInfo {
    if (![contextInfo isEqualToString:@"copyAlert"]) return;
    
    NSArray *itemsArray = [self arrayOfSelectedItems];
    __block NSMutableString *copyString = [NSMutableString string];
        
    if (returnCode == NSAlertFirstButtonReturn) {
        //Words
        [itemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [copyString appendFormat:@"%@\n",[obj objectForKey:@"characters"]];
        }];
    }
    
    else {
        //Everything
        [itemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [copyString appendFormat:@"%@\t",[obj objectForKey:@"characters"]];
            [copyString appendFormat:@"%@\t",[obj objectForKey:@"pinyin"]];
            [copyString appendFormat:@"%@\t",[[obj objectForKey:@"definition"] stringByRemovingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
            [copyString appendFormat:@"%@\t",[obj objectForKey:@"occurrences"]];
            [copyString appendFormat:@"%@\t",[obj objectForKey:@"frequency"]];
            NSString *newHSK = [obj objectForKey:@"newHSKFrequency"];
            if (![newHSK isEqualToString:@""]) [copyString appendFormat:@"HSK Level %@\t",newHSK];
            else [copyString appendString:@"\t"];
            NSString *oldHSK = [obj objectForKey:@"oldHSKFrequency"];
            if (![oldHSK isEqualToString:@""]) [copyString appendFormat:@"Old HSK Level %@\t",oldHSK];
            else [copyString appendString:@"\t"];
            [copyString appendFormat:@"%@\t",[obj objectForKey:@"textExampleStringValue"]];
            [copyString appendString:@"\n"];
         }];
        
    }
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *objectsToCopy = [NSArray arrayWithObject:copyString];
    [pasteboard writeObjects:objectsToCopy];
}

//Misc

-(void)deselectSummaryTable:(NSNotification *)notification {
    [summaryTable deselectAll:self];
}

-(void)saveSummaryArray {
    [center postNotificationName:@"SaveSummaryArray" object:self userInfo:[NSDictionary dictionaryWithObject:summaryArray forKey:@"summaryArray"]];
}

@end
