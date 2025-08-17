//
//  CRFrequency.h
//  Chinese Reader
//
//  Created by Peter Wood on 25/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"

@interface CRFrequency : NSObject <SSZipArchiveDelegate> {
    NSString *storageDirectory;
    NSString *frequencyDictLocation;
    
    NSDictionary *frequencyDict;
    
}

@property (strong) NSString *storageDirectory;
@property (strong) NSString *frequencyDictLocation;
@property (strong) NSDictionary *frequencyDict;

-(id)initWithStorageDirectory:(NSString *)directory;
+(id)shared;

-(void)setup;
-(void)loadDictionary;

-(NSArray *)frequencyArrayForString:(NSString *)string;
-(NSString *)skritFrequencyForString:(NSString *)string;
-(NSString *)oldHSKLevelForString:(NSString *)string;
-(NSString *)newHSKLevelForString:(NSString *)string;

@end
