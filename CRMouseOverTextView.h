//
//  CRMouseOverTextView.h
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSUserDefaults (MoreTypes).h"
#import "CRDictSearch.h"
#import "CRStatus.h"


@interface CRMouseOverTextView : NSTextView {
	NSNotificationCenter *center;
	NSString *puncSetString;
	NSTrackingArea *trackingArea;
	NSUserDefaults *settings;
    
	BOOL popupForAllWords;
}

@property (strong) NSTrackingArea *trackingArea;
@property (assign) BOOL popupForAllWords;

-(void)createTrackingArea;
-(void)setup;
-(void)reloadPopupState:(NSNotification *)notification;
-(void)loadSettings:(NSNotification *)notification;

-(BOOL)addingBookmark;
-(void)setAddingBookmark:(BOOL)value;
-(void)becomeActive;

@end
