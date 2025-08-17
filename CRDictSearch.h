//
//  CRDictSearch.h
//  Chinese Reader
//
//  Created by Peter Wood on 08/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRDictionary.h"

@interface CRDictSearch : NSObject

+(NSString *)wordOrCharacterFromString:(NSString *)string forCharacterAtIndex:(NSUInteger)index rangeToIndex:(NSRangePointer)charLocRange;

@end
