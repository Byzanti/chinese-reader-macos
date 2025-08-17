//
//  CRStatusBar.h
//  Chinese Reader
//
//  Created by Peter on 25/08/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRStatusBar : NSObject {
    NSUserDefaults *settings;
    NSNotificationCenter *center;
    
    NSWindow *mainWindow;
    
    IBOutlet NSTabView *tabView;
    
    IBOutlet NSProgressIndicator *editorProgressSpinner;
    IBOutlet NSTextField *editorStatusTextField;
    IBOutlet NSSlider *editorMarginSlider;
    IBOutlet NSSlider *editorTextSizeSlider;
	IBOutlet NSSlider *editorLineSpaceSlider;
    
    IBOutlet NSProgressIndicator *bookProgressSpinner;
    IBOutlet NSTextField *bookStatusTextField;
    IBOutlet NSSlider *bookTextSizeSlider;
	IBOutlet NSSlider *bookLineSpaceSlider;
    
    IBOutlet NSProgressIndicator *summaryProgressSpinner;
    IBOutlet NSTextField *summaryStatusTextField;
    
}

-(void)newStatusText:(NSNotification *)notification;

-(IBAction)changeMargin:(id)sender;
-(IBAction)changeFontSize:(id)sender;
-(IBAction)changeLineSpace:(id)sender;

-(IBAction)enterExitFullScreen:(id)sender;

-(void)updateFontSizeSlider:(NSNotification *)notification;
-(void)startSpinning:(NSNotification *)notification;
-(void)stopSpinning:(NSNotification *)notification;

@end
