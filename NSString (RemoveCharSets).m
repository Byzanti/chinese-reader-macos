//
//  NSString (RemoveCharSets).m
//  Chinese Reader
//
//  Created by Peter Wood on 03/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "NSString (RemoveCharSets).h"

@implementation NSString (RemoveCharSets)


-(NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet {
    NSString *result = @"";
    for (NSString *component in [self componentsSeparatedByCharactersInSet:characterSet])
        result = [result stringByAppendingString:component];
    
    return result;
}


-(NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet andString:(NSString *)string {
    
    NSString *result = @"";
    for (NSString *component in [self componentsSeparatedByCharactersInSet:characterSet])
        result = [result stringByAppendingString:component];
    
    [result stringByReplacingOccurrencesOfString:string withString:@""];
    
    return result;
}

@end
