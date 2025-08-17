//
//  CRCopyTableView.m
//  Chinese Reader
//
//  Created by Peter on 14/08/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRCopyTableView.h"

@implementation CRCopyTableView

-(void)copy:(id)sender {
    if ([self numberOfSelectedRows] + [self numberOfSelectedColumns] == 0) { NSBeep(); return; }
    
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(copyFromTableView:)]) [delegate copyFromTableView:self];
    else NSBeep();
}

@end
