//
//  BSAppDelegate.m
//  1blankspace
//
//  Created by VenoMKO on 11/29/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import "BSAppDelegate.h"

#pragma mark App delegate

@implementation BSAppDelegate

@synthesize mainWindowController = _mainWindowController;
@synthesize loginWindowController = _loginWindowController;
@synthesize sid;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _mainWindowController = [[BSMainWindowController alloc] init];
    [_loginWindowController showWindow:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark -
#pragma mark Keychain stuff

- (NSString *)passwordForLogin:(NSString *)login
{
    NSString    *returnString = nil;
    if (login && [login length])
    {
        char        *pwd;
        UInt32      pwdLength;
        OSStatus    err;
        
        NSString    *domain = [[NSBundle mainBundle] bundleIdentifier];
        
        err = SecKeychainFindGenericPassword(NULL,(UInt32) strlen([domain UTF8String]),
                                             [domain UTF8String],(UInt32) strlen([login UTF8String]),
                                             [login UTF8String], &pwdLength, (void **)&pwd, NULL);
        
        if (err == errSecSuccess)
        {

            returnString = [[[NSString alloc] initWithBytes:pwd length:pwdLength encoding:NSUTF8StringEncoding] autorelease];//[NSString stringWithCString:pwd length:pwdLength];
            SecKeychainItemFreeContent(NULL, pwd);
            
        } else {
            
            NSLog(@"Error: %s",GetMacOSStatusErrorString(err));
            
        }
    } else {
        
        NSLog(@"Error! Failed to get password coz login is empty!");
        
    }
    return returnString;
}

- (void)setPassword:(NSString *)password forLogin:(NSString *)login
{
    if (login && [login length] && password && [password length])
    {
        OSStatus    err;
        NSString    *domain = [[NSBundle mainBundle] bundleIdentifier];
        
        err = SecKeychainAddGenericPassword(NULL,(UInt32) strlen([domain UTF8String]),
                                            [domain UTF8String],(UInt32)strlen([login UTF8String]),
                                            [login UTF8String], (UInt32)strlen([password UTF8String]),[password UTF8String],NULL);
        
        if (err != errSecSuccess)
            NSLog(@"Error: %s",GetMacOSStatusErrorString(err));
    }
}

- (void)removePasswordForLogin:(NSString *)login
{
    OSStatus    err;
    UInt32      pLength;
    char        *pData;
    SecKeychainItemRef existingItem;
    NSString    *domain = [[NSBundle mainBundle] bundleIdentifier];
    
    err = SecKeychainFindGenericPassword(NULL,(UInt32) strlen([domain UTF8String]),
                                         [domain UTF8String],(UInt32)strlen([login UTF8String]),
                                         [login UTF8String],&pLength, (void **) &pData, &existingItem);
    
    if (err == errSecSuccess && existingItem){
        
        SecKeychainItemDelete(existingItem);
        SecKeychainItemFreeContent(NULL, pData);
        
    } else {
        
        NSLog(@"Error: %s",GetMacOSStatusErrorString(err));
        
    }
    if (existingItem && err == errSecSuccess)
        CFRelease(existingItem);
}

#pragma mark -
#pragma mark Main menu actions

- (IBAction)newRow:(id)sender
{
    if (_mainWindowController) {
        [[_mainWindowController addButton] performClick:self];
    }
}

@end

/*!
 
    NSArray category, to make it work as a data source of a table view
 
 */

#pragma mark -
#pragma mark Datasource category

@implementation NSArray (NSTableDataSource)

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (![tableColumn identifier])
        return nil;
    
    if ([[tableColumn identifier] isEqualToString:@"icon"])
        return [[self objectAtIndex:row] objectForKey:@"icon"];
    
    if ([[tableColumn identifier] isEqualToString:@"title"])
        return [[self objectAtIndex:row] objectForKey:@"title"];
    
    if ([[tableColumn identifier] isEqualToString:@"col1"])
        return [[self objectAtIndex:row] objectForKey:@"col1"];
    
    if ([[tableColumn identifier] isEqualToString:@"col2"])
        return [[self objectAtIndex:row] objectForKey:@"col2"];
    
    if ([[tableColumn identifier] isEqualToString:@"col3"])
        return [[self objectAtIndex:row] objectForKey:@"col3"];
    
    if ([[tableColumn identifier] isEqualToString:@"col4"])
        return [[self objectAtIndex:row] objectForKey:@"col4"];
    
    return [self objectAtIndex:row];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self count];
}

@end
