//
//  CRStatusBar.m
//  Chinese Reader
//
//  Created by Peter on 25/08/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRStatusBar.h"

@implementation CRStatusBar

-(void)awakeFromNib {
    settings = [NSUserDefaults standardUserDefaults];
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateFontSizeSlider:) name:@"UpdateFontSizeSlider" object:nil];
    [center addObserver:self selector:@selector(newStatusText:) name:@"newStatusText" object:nil];
    [center addObserver:self selector:@selector(startSpinning:) name:@"startProgressSpinner" object:nil];
    [center addObserver:self selector:@selector(stopSpinning:) name:@"stopProgressSpinner" object:nil];
    
    [editorMarginSlider setFloatValue:[settings floatForKey:@"margin"]];
    [editorTextSizeSlider setFloatValue:[settings floatForKey:@"fontSize"]];
	[editorLineSpaceSlider setFloatValue:[settings floatForKey:@"lineSpace"]];
    
    [bookTextSizeSlider setFloatValue:[settings floatForKey:@"fontSize"]];
	[bookLineSpaceSlider setFloatValue:[settings floatForKey:@"lineSpace"]];
}

-(void)newStatusText:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSArray *parts = [dict allKeys];
    
    [parts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:@"Editor"] || [obj isEqualToString:@"All"]) [editorStatusTextField setStringValue:[dict objectForKey:obj]];
        if ([obj isEqualToString:@"Book"] || [obj isEqualToString:@"All"]) [bookStatusTextField setStringValue:[dict objectForKey:obj]];
        if ([obj isEqualToString:@"Summary"] || [obj isEqualToString:@"All"]) [summaryStatusTextField setStringValue:[dict objectForKey:obj]];
    }];
}

-(IBAction)changeMargin:(id)sender {
    [settings setFloat:[editorMarginSlider floatValue] forKey:@"margin"];
    [settings synchronize];
    
    [center postNotificationName:@"SetEditorMargin" object:self];
}

-(IBAction)changeFontSize:(id)sender {
    NSString *tab = [[tabView selectedTabViewItem] label];
    
    CGFloat amount;
    if ([tab isEqualToString:@"Editor"]) {
        amount = [editorTextSizeSlider floatValue];
        [bookTextSizeSlider setFloatValue:amount];
        
    }
    else {
        amount = [bookTextSizeSlider floatValue];
        [editorTextSizeSlider setFloatValue:amount];
    }
    [settings setFloat:amount forKey:@"fontSize"];
    [settings synchronize];
    
    [center postNotificationName:@"SetFontStuff" object:self];
}

-(IBAction)changeLineSpace:(id)sender {
    NSString *tab = [[tabView selectedTabViewItem] label];
    
    CGFloat amount;
    if ([tab isEqualToString:@"Editor"]) {
        amount = [editorLineSpaceSlider floatValue];
        [bookLineSpaceSlider setFloatValue:amount];
    }
    else {
        amount = [bookLineSpaceSlider floatValue];
        [editorLineSpaceSlider setFloatValue:amount];
    }
	[settings setFloat:amount forKey:@"lineSpace"];
	[settings synchronize];
    
    [center postNotificationName:@"SetLineSpace" object:self];
}

-(void)updateFontSizeSlider:(NSNotification *)notification {
    [editorTextSizeSlider setFloatValue:[settings floatForKey:@"fontSize"]];
    [bookTextSizeSlider setFloatValue:[settings floatForKey:@"fontSize"]];
}

-(IBAction)enterExitFullScreen:(id)sender {
    [mainWindow
     setFrame:[mainWindow frameRectForContentRect:[[mainWindow screen] frame]]
     display:YES
     animate:YES];
}

-(void)startSpinning:(NSNotification *)notification {
    [editorProgressSpinner setHidden:NO];
    [editorProgressSpinner startAnimation:self];
    [bookProgressSpinner setHidden:NO];
    [bookProgressSpinner startAnimation:self];
    [summaryProgressSpinner setHidden:NO];
    [summaryProgressSpinner startAnimation:self];
}

-(void)stopSpinning:(NSNotification *)notification {
    [editorProgressSpinner setHidden:YES];
    [editorProgressSpinner stopAnimation:self];
    [bookProgressSpinner setHidden:YES];
    [bookProgressSpinner stopAnimation:self];
    [summaryProgressSpinner setHidden:YES];
    [summaryProgressSpinner stopAnimation:self];
}


@end
