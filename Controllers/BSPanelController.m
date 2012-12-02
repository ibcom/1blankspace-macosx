//
//  BSPanelController.m
//  1blankspace
//
//  Created by VenoMKO on 11/30/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import "BSPanelController.h"

@interface BSPanelController ()

@end

@implementation BSPanelController

- (id)init
{
    self = [super initWithWindowNibName:@"BSPanelController"];
    return self;
}

- (void)showWindow:(id)sender
{
    if ([self.window isVisible])
        return;
    
    [super showWindow:sender];
}

- (void)bringPanel
{
    [NSApp beginSheet:self.window
       modalForWindow:nil
        modalDelegate:self
       didEndSelector:nil
          contextInfo:NULL];
    [NSApp runModalForWindow:self.window];
    
    [NSApp endSheet:self.window];
    [self.window orderOut:self];
}

- (IBAction)cancelAction:(id)sender
{
    [NSApp stopModal];
    
    if (_panelOwner && _cancelSelector && [_panelOwner respondsToSelector:_cancelSelector])
        [_panelOwner performSelector:_cancelSelector];
}

- (IBAction)okAction:(id)sender
{
    [NSApp stopModal];
    
    NSDictionary    *retVal = @{@"col1" : [_col1 stringValue], @"col2" : [_col2 stringValue], @"col3" : [_col3 stringValue], @"col4" : [_col4 stringValue], @"col5" : @([_col5 selectedTag])};
    
    if (_panelOwner && _okSelector && [_panelOwner respondsToSelector:_okSelector])
        [_panelOwner performSelector:_okSelector withObject:retVal];
}

@end
