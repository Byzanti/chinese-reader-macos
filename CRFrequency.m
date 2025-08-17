//
//  CRFrequency.m
//  Chinese Reader
//
//  Created by Peter Wood on 25/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRFrequency.h"

@implementation CRFrequency

static CRFrequency *shared;

@synthesize storageDirectory;
@synthesize frequencyDictLocation;
@synthesize frequencyDict;

-(id)init {
    
    if (shared) return shared;
    
    if (self = [super init]) {
        storageDirectory = NSHomeDirectory();
    }
    
    shared = self;
    return self;
}

-(id)initWithStorageDirectory:(NSString *)directory {
    
    if (shared) return shared;
    
    if (self = [super init]) {
        storageDirectory = directory;
    }
    
    shared = self;
    return self;
}


+(id)shared {
    return shared;
}

-(void)setup {
    [self setFrequencyDictLocation:[NSString stringWithFormat:@"%@/frequencyInfo.plist",storageDirectory]];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:frequencyDictLocation]) [self loadDictionary];
    
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"frequencyInfo" ofType:@"zip"];
        [SSZipArchive unzipFileAtPath:path toDestination:storageDirectory delegate:self];
    }
    
}

-(void)loadDictionary {
    frequencyDict = [NSDictionary dictionaryWithContentsOfFile:frequencyDictLocation];
    shared = self;
}

-(void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    [self loadDictionary];
}

-(NSArray *)frequencyArrayForString:(NSString *)string {
    NSArray *array = [frequencyDict objectForKey:string];
    if (array) return array;
    return [NSArray arrayWithObjects:@" ",@" ",@" ", nil];
}

-(NSString *)skritFrequencyForString:(NSString *)string {
    NSString *freq = [[self frequencyArrayForString:string] objectAtIndex:0];
    NSUInteger freqInt = [freq intValue];
    if (freqInt >= 100) return @"4 - Very common";
    else if (freqInt >= 10 && freqInt <= 99) return @"3 - Common";
    else if (freqInt >= 2 && freqInt <= 9) return @"2 - Less common";
    else if (freqInt == 1) return @"1 - Uncommon";
    else return @"0 - No data";
}

-(NSString *)oldHSKLevelForString:(NSString *)string {
    NSString *freq = [[self frequencyArrayForString:string] objectAtIndex:1];
    return freq;
}

-(NSString *)newHSKLevelForString:(NSString *)string {
    NSString *freq = [[self frequencyArrayForString:string] objectAtIndex:2];
    return freq; 
}
                      
        



@end
