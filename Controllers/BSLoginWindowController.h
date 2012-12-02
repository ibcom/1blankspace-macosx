//
//  BSLoginWindowController.h
//  1blankspace
//
//  Created by VenoMKO on 11/29/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BSAppDelegate.h"
#import "SBJson.h"

@interface BSLoginWindowController : NSWindowController <NSURLConnectionDelegate, NSWindowDelegate> {
    NSURLConnection                                 *_loginConnection;
    NSMutableData                                   *_receiveData;
}

@property (assign) IBOutlet NSTextField             *login;
@property (assign) IBOutlet NSSecureTextField       *password;
@property (assign) IBOutlet NSTextField             *error;
@property (assign) IBOutlet NSProgressIndicator     *spinner;
@property (assign) IBOutlet NSButton                *loginButton;

@end
