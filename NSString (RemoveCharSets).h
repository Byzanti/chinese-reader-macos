//
//  NSString (RemoveCharSets).h
//  Chinese Reader
//
//  Created by Peter Wood on 03/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RemoveCharSets)

-(NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet;
-(NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet andString:(NSString *)string;

@end
