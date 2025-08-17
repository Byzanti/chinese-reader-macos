//
//  CRDictionary.h
//  Chinese Reader
//
//  Created by Peter Wood on 03/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
IMPORTANT: THE DICTIONARY 'DICTIONARY' IS SET BY CRBRAINS.
*/


@interface CRDictionary : NSObject {
    NSMutableDictionary *dictionary;
}

@property (strong) NSMutableDictionary *dictionary;

+(id)shared;

-(BOOL)itemInDictionary:(NSString *)itemName;
-(NSString *)pinyinFor:(NSString *)itemName;
-(NSString *)definitionFor:(NSString *)itemName;
-(NSString *)oppositeTradOrSimpFor:(NSString *)itemName;
-(NSString *)sourceFor:(NSString *)itemName;

@end
