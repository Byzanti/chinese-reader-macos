//
//  CRSimpTradConversion.h
//  Chinese Reader
//
//  Created by Peter Wood on 25/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"

@interface CRSimpTradConversion : NSObject <SSZipArchiveDelegate> {
    
    NSString *storageDirectory;
    
    NSDictionary *s2tCharacters;
    NSDictionary *s2tWords;
    NSDictionary *t2sCharacters;
    NSDictionary *t2sWords;
    
    NSString *s2tCharactersLocation;
    NSString *s2tWordsLocation;
    NSString *t2sCharactersLocation;
    NSString *t2sWordsLocation;

    
}

@property (strong) NSString *storageDirectory;

@property (strong) NSDictionary *s2tCharacters;
@property (strong) NSDictionary *s2tWords;
@property (strong) NSDictionary *t2sCharacters;
@property (strong) NSDictionary *t2sWords;

-(id)initWithStorageDirectory:(NSString *)directory;
+(id)shared;

-(void)setup;
-(void)loadDictionaries;

-(NSString *)simplifiedForTraditional:(NSString *)word;
-(NSString *)traditionalForSimplified:(NSString *)word;
-(NSString *)simplifiedOrTraditional:(NSString *)word;



@end
