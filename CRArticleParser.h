//
//  CRArticleParser.h
//  Chinese Reader
//
//  Created by Peter on 16/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CRDictionary.h"


@interface CRArticleParser : NSOperation {
	
	NSString *articleString;
	
	NSDictionary *skritcedictDictionary;
	NSArray *skritWordArray;
	NSArray *skritCharacterArray;
    
    NSMutableDictionary *unknownVocabWithRanges;
    
    CRDictionary *dictionary;
	
}

@property (strong) NSString *articleString;
@property (strong) NSDictionary *skritcedictDictionary;
@property (strong) NSArray *skritWordArray;
@property (strong) NSArray *skritCharacterArray;
@property (strong) NSMutableDictionary *unknownVocabWithRanges;

-(NSArray *)addDefinitionsPinyinAndOccurrencesToArray:(NSArray *)array;

@end
