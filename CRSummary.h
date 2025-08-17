//
//  CRSummary.h
//  Chinese Reader
//
//  Created by Peter Wood on 26/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRFrequency.h"
#import "CRSimpTradConversion.h"
#import "CRAddWords.h"
#import "CRMouseOverTextView.h"
#import "NSString (RemoveCharSets).h"
#import "CRCopyTableView.h"

@interface CRSummary : NSObject <NSTableViewDataSource, NSTableViewDelegate, CRCopyTableViewDelegate> {
    NSNotificationCenter *center;
    NSUserDefaults *settings;
    CRFrequency *frequency;
    CRSimpTradConversion *simpTradConversion;
    
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSTableView *summaryTable;
    IBOutlet NSScrollView *tableScrollView;
    IBOutlet NSTabView *tabView;
    IBOutlet NSView *statusBarView;
    IBOutlet NSView *summaryBarView;
    IBOutlet CRMouseOverTextView *articleView;
    
    IBOutlet NSButton *knownItemButton;
    IBOutlet NSButton *addtoSkritterButton;
    IBOutlet NSButton *copyButton;
    IBOutlet NSButton *goToButton;
    IBOutlet NSTextField *selectedItemsTextField;
    
    NSMutableArray *summaryArray;
    NSMutableArray *selectedItems;
    
    NSTimer *goToTimer;
    int timerFlash;
    NSRange highlightRange;
}

@property (strong) NSMutableArray *summaryArray;
@property (strong) NSMutableArray *selectedItems;

-(void)updateSummaryTable:(NSNotification *)notification;
-(NSAttributedString *)textExampleForWord:(NSString *)characters inText:(NSString *)text;

-(NSArray *)arrayOfSelectedItems;
-(IBAction)addToKnownWords:(id)sender;
-(IBAction)addToSkritter:(id)sender;
-(IBAction)copyToClipboard:(id)sender;
-(IBAction)goToPlaceInText:(id)sender;

//Goto highlight
-(void)highlightWord:(NSTimer *)timer;
-(void)addHighlightAttribute;
-(void)removeHighlightAttribute;

//Delegate
-(void)showSummaryBar:(BOOL)value;

//Misc
-(void)deselectSummaryTable:(NSNotification *)notification;
-(void)saveSummaryArray;

@end
