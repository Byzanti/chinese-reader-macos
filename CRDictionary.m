//
//  CRDictionary.m
//  Chinese Reader
//
//  Created by Peter Wood on 03/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRDictionary.h"

/*
 IMPORTANT: THE DICTIONARY 'DICTIONARY' IS SET BY CRBRAINS.
 */

@implementation CRDictionary

static CRDictionary *shared;

@synthesize dictionary;

-(id)init {
    
    if (shared) {
        return shared;
    }
    
    if (self = [super init]) {
        dictionary = [NSMutableDictionary dictionary];
    }
    
    shared = self;
    return self;
    
}

+(id)shared {
    return shared;
}

-(BOOL)itemInDictionary:(NSString *)itemName {
	if ([dictionary objectForKey:itemName]) return YES;
	else return NO;
}

-(NSString *)pinyinFor:(NSString *)itemName {
	NSArray *entryArray = [dictionary objectForKey:itemName];
	if (entryArray && [entryArray count] == 4) return [entryArray objectAtIndex:0]; // && [entryArray count] == 4 later added as blank entrys can be supplied using the known words override
	else return @"** Not in dictionary **";
	
}

-(NSString *)definitionFor:(NSString *)itemName {
	NSArray *entryArray = [dictionary objectForKey:itemName];
	if (entryArray && [entryArray count] == 4) return [entryArray objectAtIndex:1];
	else return @"** Not in dictionary **";
}

-(NSString *)oppositeTradOrSimpFor:(NSString *)itemName {
	NSArray *entryArray = [dictionary objectForKey:itemName];
	if (entryArray && [entryArray count] == 4) return [entryArray objectAtIndex:2];
	else return @"";
}

-(NSString *)sourceFor:(NSString *)itemName {
	NSArray *entryArray = [dictionary objectForKey:itemName];
	if (entryArray && [entryArray count] == 4) return [entryArray objectAtIndex:3];
	else return @"";
}


@end
