//
//  Chinese_ReaderAppDelegate.h
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CRStatus.h"

@interface Chinese_ReaderAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *__unsafe_unretained window;
	NSNotificationCenter *center;
    NSUserDefaults *settings;
}

@property (unsafe_unretained) IBOutlet NSWindow *window;

-(void)terminateCR:(NSNotification *)notification;
-(void)dontTerminateCR:(NSNotification *)notification;

-(void)loadLabels;

@end
