//
//  NSUserDefaults (MoreTypes).m
//  Chinese Reader
//
//  Created by Peter on 24/05/2012.
//  Copyright 2012 Byzanti. All rights reserved.
//

#import "NSUserDefaults (MoreTypes).h"


@implementation NSUserDefaults (MoreTypes)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey {
    NSData* theData = [NSArchiver archivedDataWithRootObject:aColor] ;
    [self setObject:theData forKey:aKey] ;
}

- (NSColor*)colorForKey:(NSString *)aKey {
    NSColor* theColor = nil ;
    NSData* theData = [self dataForKey:aKey] ;
    if (theData != nil) {
        theColor = (NSColor*)[NSUnarchiver
							  unarchiveObjectWithData:theData] ;
    }
	
    return theColor ;
}

@end