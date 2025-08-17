//
//  CRSaveDrawerController.h
//  Chinese Reader
//
//  Created by Peter Wood on 31/05/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRSaveLoad.h"
#import "CRMouseOverTextView.h"
#import "NSString (RemoveCharSets).h"
#import "CRStatus.h"
#import "LTKeyPressTableView.h"
#import "CRMainWindows.h"

@interface CRDrawerController : NSObject <NSTableViewDataSource, NSTableViewDelegate, LTKeyPressTableViewDelegate, NSAlertDelegate, NSTextFieldDelegate> {
    NSNotificationCenter *center;
    NSUserDefaults *settings;
    
    NSTimer *updateTimer;
    NSTimer *flashingTimer;
    NSTimer *endFlashingTimer;
    
    NSMutableArray *summaryArray;
    
    //main windows
    IBOutlet NSWindow *mainWindow;
    IBOutlet CRMouseOverTextView *articleView;
    
    //Drawer windows
    IBOutlet NSDrawer *drawer;
    IBOutlet NSButton *saveAndLoadButton;
    IBOutlet NSButton *bookmarksButton;
    IBOutlet NSTabView *drawerTabView;
    IBOutlet NSPopUpButton *saveLoadPopUpButton;
    
    //Save Load
    IBOutlet LTKeyPressTableView *saveLoadTable;
    IBOutlet NSButton *saveTextButton;
    IBOutlet NSButton *deleteTextButton;
    IBOutlet NSTextField *saveNameTextField;
    IBOutlet NSTextField *searchTextField;
    
    NSString *alertResponse;
    
    BOOL searching;
    
    NSArray *savedIndex;
    
    NSUInteger selectedRowIndex;

}

@property (strong) NSArray *savedIndex;
@property (strong) NSMutableArray *summaryArray;


//Startup
-(void)startUpLoadLastFile:(NSNotification *)notification;

//Actions
-(IBAction)showSaveAndLoad:(id)sender;
-(IBAction)showBookmarks:(id)sender;

//Save and load input
-(IBAction)saveAs:(id)sender;
-(IBAction)save:(id)sender;
-(IBAction)saveAsMenu:(id)sender;
-(IBAction)deleteItem:(id)sender;
-(void)search:(NSNotification *)notification;
-(void)changeSaveFieldColour:(NSTimer *)timer;
-(void)invalidateTimer:(NSTimer *)timer;
-(IBAction)orderByCreation:(id)sender;
-(IBAction)orderByLastViewed:(id)sender;

//Tables
-(void)updateIndex;
-(void)loadFileName:(NSString *)fileName;
-(void)selectItemWithFileName:(NSString *)fileName;
-(void)selectItemWithIndex:(NSUInteger)index;
-(void)selectCurrentItem;
-(void)deleteFile:(NSString *)fileName;

//Alerts
-(void)saveDialogNotification:(NSNotification *)notification;
-(void)saveDialog;

//Misc
-(NSString *)fileNameWithoutTime:(NSAttributedString *)fileName;
-(NSString *)fileNameForCurrentDocument;
-(BOOL)setCurrentDocument:(NSString *)fileName;
-(void)saveSummaryArray:(NSNotification *)notification;
-(void)saveSummaryAsWordsRemoved;
-(void)newDoc;
    
@end
