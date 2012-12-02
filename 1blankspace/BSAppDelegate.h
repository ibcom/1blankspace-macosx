//
//  BSAppDelegate.h
//  1blankspace
//
//  Created by VenoMKO on 11/29/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BSMainWindowController.h"
#import "BSLoginWindowController.h"

@class BSMainWindowController, BSLoginWindowController;

@interface BSAppDelegate : NSObject <NSApplicationDelegate> {
    BSLoginWindowController                             *_loginWindowController;
    BSMainWindowController                              *_mainWindowController;
    NSString                                            *sid;
}


@property (assign) IBOutlet BSLoginWindowController     *loginWindowController;
@property (retain) NSString                             *sid;
@property (assign) BSMainWindowController               *mainWindowController;


- (NSString *)passwordForLogin:(NSString *)login;
- (void)setPassword:(NSString *)password forLogin:(NSString *)login;
- (void)removePasswordForLogin:(NSString *)login;

@end

@interface NSArray (NSTableDataSource) <NSTableViewDataSource>

@end