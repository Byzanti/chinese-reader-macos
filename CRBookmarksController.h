//
//  CRBookmarksController.h
//  Chinese Reader
//
//  Created by Peter Wood on 02/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString (RemoveCharSets).h"
#import "CRStatus.h"
#import "LTKeyPressTableView.h"
#import "NSUserDefaults (MoreTypes).h"
#import "CRMouseOverTextView.h"

@interface CRBookmarksController : NSObject <NSTableViewDataSource, NSTableViewDelegate, LTKeyPressTableViewDelegate> {
    NSNotificationCenter *center;
    NSUserDefaults *settings;
    
    //Main window
    IBOutlet CRMouseOverTextView *articleView;
    
    //Bookmarks
    IBOutlet LTKeyPressTableView *bookmarksTable;
    IBOutlet NSButton *addBookmarkButton;
    IBOutlet NSButton *deleteBookmarkButton;
    
    NSMutableArray *bookmarksArray;
    NSMutableArray *bookmarksRangeArray;
}

@property (strong) NSMutableArray *bookmarksArray;
@property (strong) NSMutableArray *bookmarksRangeArray;

//Add attributes
-(void)addBookmarkAttributes:(NSNotification *)notification;

//Update
-(void)updateBookmarks;

-(IBAction)addBookmark:(id)sender;
-(IBAction)removeBookmarks:(id)sender;
-(void)removeBookmarkObject:(NSAttributedString *)bookmark;

@end
