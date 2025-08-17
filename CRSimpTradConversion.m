//
//  CRSimpTradConversion.m
//  Chinese Reader
//
//  Created by Peter Wood on 25/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRSimpTradConversion.h"

@implementation CRSimpTradConversion

static CRSimpTradConversion *shared;

@synthesize storageDirectory;

@synthesize s2tCharacters;
@synthesize s2tWords;

@synthesize t2sCharacters;
@synthesize t2sWords;

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
    [self setStorageDirectory:[NSString stringWithFormat:@"%@/SimpTradConversion",storageDirectory]];
    s2tCharactersLocation = [NSString stringWithFormat:@"%@/s2t-characters.plist",storageDirectory];
    s2tWordsLocation = [NSString stringWithFormat:@"%@/s2t-words.plist",storageDirectory];
    t2sCharactersLocation = [NSString stringWithFormat:@"%@/t2s-characters.plist",storageDirectory];
    t2sWordsLocation = [NSString stringWithFormat:@"%@/t2s-words.plist",storageDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:s2tCharactersLocation]) [self loadDictionaries];
    
    else {
        NSString *simpTradPath = [[NSBundle mainBundle] pathForResource:@"simpTradConversion" ofType:@"zip"];
        [SSZipArchive unzipFileAtPath:simpTradPath toDestination:storageDirectory delegate:self];
    }
    
}

-(void)loadDictionaries {
    s2tCharacters = [NSDictionary dictionaryWithContentsOfFile:s2tCharactersLocation];
    s2tWords = [NSDictionary dictionaryWithContentsOfFile:s2tWordsLocation];
    t2sCharacters = [NSDictionary dictionaryWithContentsOfFile:t2sCharactersLocation];
    t2sWords = [NSDictionary dictionaryWithContentsOfFile:t2sWordsLocation];
}

-(void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    [self loadDictionaries];
}

-(NSString *)simplifiedForTraditional:(NSString *)word {

    NSString *simplified = [t2sWords objectForKey:word];
    if (simplified) return simplified;
    
    NSMutableString *simplifyCharByChar = [NSMutableString string];
    for (int i = 0; i < [word length]; i++) {
        NSString *character = [word substringWithRange:NSMakeRange(i, 1)];
        [simplifyCharByChar appendString:[self convertTraditionalCharacter:character]];
        }
    
    return [simplifyCharByChar copy];
}

-(NSString *)traditionalForSimplified:(NSString *)word {

    NSString *traditional = [s2tWords objectForKey:word];
    if (traditional) return traditional;
    
    NSMutableString *convertCharByChar = [NSMutableString string];
    for (int i = 0; i < [word length]; i++) {
        NSString *character = [word substringWithRange:NSMakeRange(i, 1)];
        [convertCharByChar appendString:[self convertSimplifiedCharacter:character]];
    }
    
    return [convertCharByChar copy];
}

-(NSString *)simplifiedOrTraditional:(NSString *)word {
    //Same means that the word is the same in simp and traditional
    //Mixed means, either the input is mixed, or it doesn't know!
    
    //Checking words
    NSString *t2s = [t2sWords objectForKey:word];
    NSString *s2t = [s2tWords objectForKey:word];
    if (t2s && !s2t) return @"traditional";
    if (!t2s && s2t) return @"simplified";
    if (t2s && s2t) return @"same";
    
    //Checking by characters
    NSString *simplified = [self simplifiedForTraditional:word];
    NSString *traditional = [self traditionalForSimplified:word];
    
    if ([simplified isEqualToString:word] && ![traditional isEqualToString:word]) return @"simplified";
    else if (![simplified isEqualToString:word] && [traditional isEqualToString:word]) return @"traditional";
    else if ([simplified isEqualToString:word] && [traditional isEqualToString:word]) return @"same";
    else return @"mixed";
    
}

//Used internally
//subStringToIndex:1 is because some characters have multiple conversion possibilities
//Words including these should already been handled by the 'words' dictionary
//If not then subStringToIndex:1 will (not 100% checked) return the most common form
-(NSString *)convertSimplifiedCharacter:(NSString *)character {
    NSString *traditional = [[s2tCharacters objectForKey:character] substringToIndex:1];
    if (traditional) return traditional;
    else return character;
}

-(NSString *)convertTraditionalCharacter:(NSString *)character {
    NSString *simplified = [[t2sCharacters objectForKey:character] substringToIndex:1];
    if (simplified) return simplified;
    else return character;
}




@end
