//
//  CRSaveDrawerController.m
//  Chinese Reader
//
//  Created by Peter Wood on 31/05/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRDrawerController.h"
#import "CRMainWindows.h"

@implementation CRDrawerController

@synthesize savedIndex;
@synthesize summaryArray;

-(void)awakeFromNib {
    center = [NSNotificationCenter defaultCenter];
    settings = [NSUserDefaults standardUserDefaults];
    
    [center addObserver:self selector:@selector(search:) name:NSControlTextDidChangeNotification object:searchTextField];
    [center addObserver:self selector:@selector(newDoc) name:@"newDoc" object:nil];
    [center addObserver:self selector:@selector(saveDialogNotification:) name:@"saveDialog" object:nil];
    [center addObserver:self selector:@selector(showSaveAndLoad:) name:@"showSaveAndLoad" object:nil];
    [center addObserver:self selector:@selector(showBookmarks:) name:@"showBookmarks" object:nil];
    [center addObserver:self selector:@selector(updateIndex) name:@"UpdateSaveLoadIndex" object:nil];
    [center addObserver:self selector:@selector(saveSummaryArray:) name:@"SaveSummaryArray" object:nil];
    [center addObserver:self selector:@selector(saveSummaryAsWordsRemoved) name:@"SaveSummaryAsWordsRemoved" object:nil];
    [center addObserver:self selector:@selector(startUpLoadLastFile:) name:@"startUpLoadLastFile" object:nil];
    
    [CRStatus setTextChanged:NO];
    [self updateIndex];
    
    //Loads up the new text into bookmarks and book viewer
    [center postNotificationName:@"UpdateBookmarks" object:self];
    [center postNotificationName:@"UpdateBookText" object:self];
    
    [saveAndLoadButton setState:NSOnState];

    
    if ([[settings objectForKey:@"saveLoadStyle"] isEqualToString:@"creation"]) [saveLoadPopUpButton selectItemAtIndex:0];
    else [saveLoadPopUpButton selectItemAtIndex:1];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateIndex) userInfo:nil repeats:YES];
    
    summaryArray = [NSMutableArray array];

}

-(void)startUpLoadLastFile:(NSNotification *)notification {
    if ([settings boolForKey:@"loadLastViewed"] && [self fileNameForCurrentDocument] != nil) [self loadFileName:[self fileNameForCurrentDocument]];
    else [self newDoc];
}

//Main buttons

-(IBAction)showSaveAndLoad:(id)sender {
    [saveAndLoadButton setState:NSOnState];
    [bookmarksButton setState:NSOffState];
    [drawerTabView selectTabViewItemAtIndex:0];
}

-(IBAction)showBookmarks:(id)sender {
    [saveAndLoadButton setState:NSOffState];
    [bookmarksButton setState:NSOnState];
    [drawerTabView selectTabViewItemAtIndex:1];
}

//Save and load input

-(IBAction)saveAs:(id)sender {
    NSString *textFieldString = [[saveNameTextField stringValue] stringByRemovingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    int length = [textFieldString length];
    if (length > 20) length = 20;
    NSString *fileName = [textFieldString substringToIndex:length];
    
    if ([CRSaveLoad fileNameExists:fileName]) { 
        
        NSAlert *alert = [[NSAlert alloc] init]; 
        [alert addButtonWithTitle:@"OK"]; 
        
        [alert setMessageText:@"File name already exists"]; 
        [alert setInformativeText:@"Please choose a different name"]; 
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        
        return;
    }
    
    //NSAttributedString *articleAtString = [CRMainWindows articleAtString];
    NSAttributedString *articleAtString = [articleView textStorage];
    
    if ([CRSaveLoad saveText:articleAtString withSummary:summaryArray forFileName:fileName]) [self updateIndex];
    else NSLog(@"Save failed");
    
    [self setCurrentDocument:fileName];
    
    [CRStatus setTextChanged:NO];
    [saveNameTextField setStringValue:@""];
    
}


-(IBAction)save:(id)sender {
    
    //NSAttributedString *articleAtString = [CRMainWindows articleAtString];
    NSAttributedString *articleAtString = [articleView textStorage];

    NSString *fileName = [self fileNameForCurrentDocument];
    if (!fileName) { [self saveAsMenu:self]; return; }

    if ([CRSaveLoad fileNameExists:fileName]) {
        
        [CRSaveLoad saveText:articleAtString withSummary:summaryArray forFileName:fileName];
        
        [CRStatus setAllStatusTexts:[NSString stringWithFormat:@"Saved %@",fileName]];
        [CRStatus setTextChanged:NO];
    }
    else [self saveAsMenu:self];
}

-(IBAction)saveAsMenu:(id)sender {
    [drawer open];
    [endFlashingTimer invalidate];
    [self invalidateTimer:nil];
    flashingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeSaveFieldColour:) userInfo:nil repeats:YES];
    endFlashingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(invalidateTimer:) userInfo:nil repeats:NO];
}

-(IBAction)deleteItem:(id)sender {    
    //Gets an array of all the objects that should be deleted
    NSIndexSet *indexSet = [saveLoadTable selectedRowIndexes];    
    NSUInteger index=[indexSet firstIndex];
    NSMutableArray *fileNameArray = [NSMutableArray array];
    
    while (index != NSNotFound) {
        
        [fileNameArray addObject:[self fileNameWithoutTime:[savedIndex objectAtIndex:index]]];
        index = [indexSet indexGreaterThanIndex:index];
        
    }
    
    //Then deletes all the objects
    for (int i = 0; i < [fileNameArray count]; i++) [self deleteFile:[fileNameArray objectAtIndex:i]];
}

-(void)search:(NSNotification *)notification {
    NSString *searchString = [searchTextField stringValue];
    
    if ([searchString isEqualToString:@""]) { 
        searching = NO;
        [self updateIndex];
    }
    
    else {
        searching = YES;
        [saveLoadTable deselectAll:self];
        [self updateIndex];
    }
}

-(void)changeSaveFieldColour:(NSTimer *)timer {
    if ([saveNameTextField backgroundColor] == [NSColor redColor]) {
        [saveNameTextField setBackgroundColor:[NSColor whiteColor]];
    }
    else { 
        [saveNameTextField setBackgroundColor:[NSColor redColor]];
    }
    [saveNameTextField display];
}

-(void)invalidateTimer:(NSTimer *)timer {
    [flashingTimer invalidate];   
    if ([saveNameTextField backgroundColor] == [NSColor redColor]) [saveNameTextField setBackgroundColor:[NSColor whiteColor]];
    [saveNameTextField display];
}

-(BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    [self invalidateTimer:nil];
    return YES;
}

-(IBAction)orderByCreation:(id)sender {
    [settings setObject:@"creation" forKey:@"saveLoadStyle"];
    [self updateIndex];
}

-(IBAction)orderByLastViewed:(id)sender {
    [settings setObject:@"lastViewed" forKey:@"saveLoadStyle"];
    [self updateIndex];
}



//Tables etc

-(void)updateIndex {
    if (!searching) [self setSavedIndex:[CRSaveLoad latestIndex]];
    else if (searching) {
        NSString *searchString = [searchTextField stringValue];
        [self setSavedIndex:[CRSaveLoad latestSearchedIndex:searchString]];
    }
    [saveLoadTable reloadData];
    [self selectCurrentItem];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [savedIndex count];

}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [savedIndex objectAtIndex:row];
}


//Should load new item
-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    
    if (![CRStatus textChanged]) return YES;
    
    selectedRowIndex = rowIndex;
    
    [saveLoadTable setEnabled:NO];
    
    alertResponse = @"loadOther";
    [self saveDialog];
    
    return NO;
    
}


//Load new item
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    
    //If more than one is selected, does nothing
    NSIndexSet *indexSet = [saveLoadTable selectedRowIndexes];
	int indexCount = [indexSet count];
	if (indexCount == 0 || indexCount > 1) return;
    
    int index = [indexSet firstIndex];
    
    //Does the file exist?
    NSString *fileName = [self fileNameWithoutTime:[savedIndex objectAtIndex:index]];
    if (!fileName) return;
    if ([fileName isEqualToString:[self fileNameForCurrentDocument]]) return;
    
    //Loads the file
    [self loadFileName:fileName];
    
    //Updates save load table accordingly
    [self updateIndex];
    
    //Update bookmarks
    [center postNotificationName:@"UpdateBookmarks" object:self];
    
}

-(void)loadFileName:(NSString *)fileName {
    
    //Updates labels
    [CRStatus setAllStatusTexts:[NSString stringWithFormat:@"Loaded %@",fileName]];
    
    //Loads the text
    NSAttributedString *text = [CRSaveLoad textForFileName:fileName];
    NSTextStorage *articleViewTextStorage = [articleView textStorage];
    
    [articleViewTextStorage beginEditing];
    [articleViewTextStorage setAttributedString:text];
    [articleViewTextStorage endEditing];
    
    //Loads the summary
    NSDictionary *summaryDict = [NSDictionary dictionaryWithObject:[CRSaveLoad summaryForFileName:fileName] forKey:@"summaryArray"];
    [center postNotificationName:@"LoadSummaryArray" object:self userInfo:summaryDict];
    
    //Updates the text formatting
    [center postNotificationName:@"LoadSettings" object:self];
    [center postNotificationName:@"UpdateBookText" object:self];
    
    [CRStatus setTextChanged:NO];
    
    //Updates last viewed
    [CRSaveLoad saveLastViewedData:[NSDate date] forFileName:fileName];
    
    //Sets the current viewed document
    [self setCurrentDocument:fileName];
}

-(void)selectItemWithFileName:(NSString *)fileName {
    NSMutableArray *currentArray = [NSMutableArray array];
    [savedIndex enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [currentArray addObject:[self fileNameWithoutTime:obj]];   
    }];
    
    NSUInteger index = [currentArray indexOfObject:fileName];
    if (index == NSNotFound) return;
    
    //stops looping
    if ([saveLoadTable selectedRow] == index) return;

    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
   [saveLoadTable selectRowIndexes:indexSet byExtendingSelection:NO];
}

-(void)selectItemWithIndex:(NSUInteger)index {    
    //stops looping
    if ([saveLoadTable selectedRow] == index) return;
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [saveLoadTable selectRowIndexes:indexSet byExtendingSelection:NO];
}

-(void)selectCurrentItem {
    NSString *fileName = [settings objectForKey:@"currentDocument"];
    if (fileName) [self selectItemWithFileName:fileName];
    else [saveLoadTable deselectAll:self];
}

-(void)deleteFile:(NSString *)fileName {
    if ([CRSaveLoad deleteSavedFile:fileName]) [self updateIndex];
    [self tableViewSelectionDidChange:nil];
}

//Alerts

-(void)saveDialogNotification:(NSNotification *)notification {
    NSString *response = [[notification userInfo] objectForKey:@"response"];
    alertResponse = response;
    [self saveDialog];
}

-(void)saveDialog {
    
    NSString *fileName = [self fileNameForCurrentDocument];
    
    //If file already exists
    if ([CRStatus textChanged] && fileName) {
        
        NSAlert *saveCurrentChangesAlert = [[NSAlert alloc] init]; 
        [saveCurrentChangesAlert addButtonWithTitle:@"Save"]; 
        [saveCurrentChangesAlert addButtonWithTitle:@"Don't save"];
        if ([alertResponse isEqualToString:@"loadOther"] || [alertResponse isEqualToString:@"newDoc"]) [saveCurrentChangesAlert addButtonWithTitle:@"Cancel"];
    
        
        [saveCurrentChangesAlert setMessageText:@"Save changes?"]; 
        [saveCurrentChangesAlert setInformativeText:[NSString stringWithFormat:@"Do you want to save the changes you've made to %@? This includes any bookmarks added.",fileName]]; 
        [saveCurrentChangesAlert setAlertStyle:NSInformationalAlertStyle];
        [saveCurrentChangesAlert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:@"saveCurrentChanges"];
        
    }
    
    //If file doesn't exist
    else if ([CRStatus textChanged] && !fileName) {
        
        NSAlert *saveNewAlert = [[NSAlert alloc] init]; 
        [saveNewAlert addButtonWithTitle:@"Save"];
        [saveNewAlert addButtonWithTitle:@"Don't save"];
        if ([alertResponse isEqualToString:@"loadOther"] || [alertResponse isEqualToString:@"newDoc"]) [saveNewAlert addButtonWithTitle:@"Cancel"];
        
        [saveNewAlert setMessageText:@"Save new text?"]; 
        [saveNewAlert setInformativeText:@"Do you want to save the current text?"]; 
        [saveNewAlert setAlertStyle:NSInformationalAlertStyle];
        [saveNewAlert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:@"saveNewAlert"];
        
    }
    
}

-(void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(NSString *)contextInfo {
    
    if ([contextInfo isEqualToString:@"saveCurrentChanges"]) {
        if (returnCode == NSAlertFirstButtonReturn) {
            //Save
            [self save:self];
            if ([alertResponse isEqualToString:@"loadOther"]) [self selectItemWithIndex:selectedRowIndex];
            if ([alertResponse isEqualToString:@"newDoc"]) [self newDoc];
            if ([alertResponse isEqualToString:@"terminateApp"]) [center postNotificationName:@"terminateCR" object:self];
            if ([alertResponse isEqualToString:@"closeWindow"]) { [self newDoc]; [mainWindow close]; }
            
        }
        if (returnCode == NSAlertSecondButtonReturn) {
            //Don't Save
            if ([alertResponse isEqualToString:@"loadOther"]) [self selectItemWithIndex:selectedRowIndex];
            if ([alertResponse isEqualToString:@"newDoc"]) [self newDoc];
            if ([alertResponse isEqualToString:@"terminateApp"]) [center postNotificationName:@"terminateCR" object:self];
            if ([alertResponse isEqualToString:@"closeWindow"]) { [self newDoc]; [mainWindow close]; }
        }
        //If cancel, does nothing
    }
    
    
    if ([contextInfo isEqualToString:@"saveNewAlert"]) {
        if (returnCode == NSAlertFirstButtonReturn) {
            //Flash save as
            [center postNotificationName:@"dontTerminateCR" object:self];
            [self saveAsMenu:self];
        }
        if (returnCode == NSAlertSecondButtonReturn) {
            //Don't Save
            if ([alertResponse isEqualToString:@"loadOther"]) [self selectItemWithIndex:selectedRowIndex];
            if ([alertResponse isEqualToString:@"newDoc"]) [self newDoc];
            if ([alertResponse isEqualToString:@"terminateApp"]) [center postNotificationName:@"terminateCR" object:self];
            if ([alertResponse isEqualToString:@"closeWindow"]) { [self newDoc]; [mainWindow close]; }
            
        }
        //If cancel, does nothing
    }
    
    [saveLoadTable setEnabled:YES];
    
}

             
//Misc

-(NSString *)fileNameWithoutTime:(NSAttributedString *)fileName {
    NSArray *array = [[fileName string] componentsSeparatedByString:@"\n"];
    
    return [array objectAtIndex:0];
}

-(NSString *)fileNameForCurrentDocument {
    NSString *fileName = [settings objectForKey:@"currentDocument"];
    return fileName;
}

-(BOOL)setCurrentDocument:(NSString *)fileName {
    [settings setObject:fileName forKey:@"currentDocument"];
    [settings synchronize];
    return YES;
}

-(void)saveSummaryArray:(NSNotification *)notification {
    //Keeps the local version of the Summary Array updated in case it is called to be saved
    summaryArray = [[notification userInfo] objectForKey:@"summaryArray"];
}

-(void)saveSummaryAsWordsRemoved {
    [CRSaveLoad saveSummary:summaryArray forFileName:[self fileNameForCurrentDocument]];
}

-(void)newDoc {
    [articleView setString:@""];
    [center postNotificationName:@"ClearSummaryTable" object:self];
    [center postNotificationName:@"UpdateBookText" object:self];
    [center postNotificationName:@"ResetTextPosition" object:self];
    [center postNotificationName:@"UpdateBookmarks" object:self];
    [settings setObject:nil forKey:@"currentDocument"];
    [CRStatus setTextChanged:NO];
    [saveLoadTable deselectAll:self];
    [CRStatus setAllStatusTexts:@"New document"];
    [CRStatus setCheckedText:NO];
}

@end
