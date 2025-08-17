//
//  CRMainWindowsDelegate.m
//  Chinese Reader
//
//  Created by Peter on 18/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRMainWindowsDelegate.h"


@implementation CRMainWindowsDelegate

-(id)init {
	if (self = [super init]) {
		center = [NSNotificationCenter defaultCenter];
	}
	return self;
}

-(void)windowDidResize:(NSNotification *)notification {
	[center postNotificationName:@"Resized" object:self];
	
}

-(BOOL)windowShouldClose:(id)sender {
    if (![CRStatus textChanged]) return YES;
    else { 
        [center postNotificationName:@"saveDialog" object:self userInfo:[NSDictionary dictionaryWithObject:@"closeWindow" forKey:@"response"]];
        return NO;
    }
}


@end
