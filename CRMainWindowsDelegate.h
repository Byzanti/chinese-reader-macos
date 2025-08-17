//
//  CRMainWindowsDelegate.h
//  Chinese Reader
//
//  Created by Peter on 18/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CRStatus.h"


@interface CRMainWindowsDelegate : NSObject <NSWindowDelegate> {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTabView *tabView;
	
	NSNotificationCenter *center;
}

@end
