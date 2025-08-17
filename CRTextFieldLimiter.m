//
//  CRTextFieldLimiter.m
//  Chinese Reader
//
//  Created by Peter Wood on 01/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRTextFieldLimiter.h"

@implementation CRTextFieldLimiter

- (BOOL)isPartialStringValid:(NSString **)partialString
       proposedSelectedRange:(NSRangePointer)proposedSelRange
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error 
{
    
    if ([*partialString length] > 20) { 
        return NO;
    }
    
    
    return YES;
}


@end
