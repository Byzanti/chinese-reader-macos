//
//  Chinese_ReaderAppDelegate.m
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Chinese_ReaderAppDelegate.h"

@implementation Chinese_ReaderAppDelegate

@synthesize window;

-(id)init {
    if (self = [super init]) {
        center = [NSNotificationCenter defaultCenter];
        settings = [NSUserDefaults standardUserDefaults];
        [center addObserver:self selector:@selector(terminateCR:) name:@"terminateCR" object:nil];
        [center addObserver:self selector:@selector(dontTerminateCR:) name:@"dontTerminateCR" object:nil];
        
        //[window setAcceptsMouseMovedEvents:YES];
        
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    settings = [NSUserDefaults standardUserDefaults];
    if ([settings boolForKey:@"firstTime"]) [center postNotificationName:@"UseWithSkritterAlert" object:self];
    else {
        [self loadLabels];
        [center postNotificationName:@"startUpLoadLastFile" object:self];
    }
}


-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if ([CRStatus textChanged]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"terminateApp" forKey:@"response"];
        [center postNotificationName:@"saveDialog" object:self userInfo:dict];
        return NSTerminateLater;
    }
    else return NSTerminateNow;
}


-(void)applicationWillTerminate:(NSNotification *)sender {
    
    if ([settings boolForKey:@"firstTime"]) [settings setBool:NO forKey:@"firstTime"];

	[center postNotificationName:@"WillTerminate" object:self];
}

-(void)terminateCR:(NSNotification *)notification {
    [[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
}

-(void)dontTerminateCR:(NSNotification *)notification {
    [[NSApplication sharedApplication] replyToApplicationShouldTerminate:NO];
}


//App finished launching
-(void)loadLabels {
    
    if ([settings boolForKey:@"loadLastViewed"] == NO) {
        NSString *all = @"New document";
        NSDictionary *newStatusDict = [NSDictionary dictionaryWithObject:all forKey:@"All"];
        [center postNotificationName:@"newStatusText" object:self userInfo:newStatusDict];
        
        return;
    }
}

-(void)applicationDidBecomeActive:(NSNotification *)notification {
 //   [center postNotificationName:@"becomeActive" object:self];
    
}

@end
