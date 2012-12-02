//
//  BSLoginWindowController.m
//  1blankspace
//
//  Created by VenoMKO on 11/29/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import "BSLoginWindowController.h"

@implementation BSLoginWindowController

- (void)showWindow:(id)sender
{
    NSString        *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
    BOOL            autoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"];
    
    if (login && [login length] && autoLogin) {
        
        NSString    *password = [(BSAppDelegate *)[NSApp delegate] passwordForLogin:login];
        
        if (password && [password length]) {
            [_login setStringValue:login];
            [_password setStringValue:password];
        }
    }
    [super showWindow:sender];
}

- (void)enableInterface:(BOOL)aFlag
{
    [_login setEnabled:aFlag];
    [_password setEnabled:aFlag];
    [_loginButton setEnabled:aFlag];
}

- (IBAction)loginAction:(id)sender
{
    if (![[_login stringValue] length] || ![[_password stringValue] length]) {
        [_error setHidden:NO];
    }
    [_error setHidden:YES];
    [_spinner startAnimation:nil];
    [self enableInterface:NO];
    
    
    NSMutableURLRequest        *loginRequest = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.mydigitalspacelive.com/ondemand/logon/"]] autorelease];
    NSData      *postData = [[NSString stringWithFormat:@"logon=%@&password=%@",[_login stringValue],[_password stringValue]] dataUsingEncoding:NSUTF8StringEncoding];
    
    [loginRequest setHTTPMethod:@"POST"];
    [loginRequest setHTTPBody:postData];
    _receiveData = [[NSMutableData alloc] init];
    _loginConnection = [[NSURLConnection alloc] initWithRequest:loginRequest delegate:self startImmediately:YES];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString        *responseString =[[NSString alloc] initWithBytes:[_receiveData bytes] length:[_receiveData length] encoding:NSUTF8StringEncoding];
    NSDictionary    *response;
    SBJsonParser    *parser = [[SBJsonParser alloc] init];
    
    response = [parser objectWithString:responseString];
    
    [parser release];
    [responseString release];
    [_spinner stopAnimation:nil];
    [self enableInterface:YES];
    
    if ([[response objectForKey:@"status"] isEqualToString:@"ER"]) {
        NSDictionary    *errorDesc = [response objectForKey:@"error"];
        
        if ([[errorDesc objectForKey:@"errorcode"] isEqualToString:@"1"]) { // No logon or password
            [_error setHidden:NO];
        } else if ([[errorDesc objectForKey:@"errorcode"] isEqualToString:@"2"]) { // Incorrect logon or password
            [_error setHidden:NO];
        }
    } else {
        NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
        [[NSApp delegate] setSid:[response objectForKey:@"sid"]];
        if ([defaults boolForKey:@"rememberMe"]) {
            [defaults setObject:[_login stringValue] forKey:@"login"];
            [[NSApp delegate] setPassword:[_password stringValue] forLogin:[_login stringValue]];
        } else if ([defaults objectForKey:@"login"]) {
            [[NSApp delegate] removePasswordForLogin:[defaults objectForKey:@"login"]];
            [defaults removeObjectForKey:@"login"];
        }
        
        [self.window close];
        [[[NSApp delegate] mainWindowController] showWindow:nil];
        [connection release];
    }
    
    [_receiveData release];
    _receiveData = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_spinner stopAnimation:nil];
    [self enableInterface:YES];
    [NSApp presentError:error];
    [_receiveData release];
    _receiveData = nil;
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receiveData appendData:data];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

- (IBAction)cancelAction:(id)sender
{
    if (_loginConnection) {
        [_loginConnection cancel];
        [_loginConnection release];
        _loginConnection = nil;
        [_spinner stopAnimation:nil];
        [self enableInterface:YES];
    } else
        [[NSApplication sharedApplication] terminate:nil];
}

@end
