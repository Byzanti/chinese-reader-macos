//
//  NSImage-Utilities.m
//  Chinese Reader
//
//  Created by Peter on 19/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NSImage-Utilities.h"


@implementation NSImage (Utilities)

-(NSRect)proportionalRectForTargetRect:(NSRect)targetRect {
	
	if (NSEqualSizes(self.size, targetRect.size)) return targetRect;
	
	NSSize imageSize = self.size;
	CGFloat sourceWidth	= imageSize.width; 
	CGFloat sourceHeight = imageSize.height;
	
	CGFloat widthAdjust = targetRect.size.width / sourceWidth;
	CGFloat heightAdjust = targetRect.size.height / sourceHeight; 
	CGFloat scaleFactor = 1.0;
	
	if (widthAdjust < heightAdjust) scaleFactor = widthAdjust; 
	else scaleFactor = heightAdjust;
	
	CGFloat finalWidth = sourceWidth * scaleFactor; 
	CGFloat finalHeight = sourceHeight * scaleFactor; 
	NSSize finalSize = NSMakeSize ( finalWidth, finalHeight );
	
	NSRect finalRect; finalRect.size = finalSize;
	
	finalRect.origin = targetRect.origin;
	finalRect.origin.x += (targetRect.size.width - finalWidth) * 0.5;
	finalRect.origin.y += (targetRect.size.height - finalHeight) * 0.5;
	
	return NSIntegralRect ( finalRect );
}

@end
