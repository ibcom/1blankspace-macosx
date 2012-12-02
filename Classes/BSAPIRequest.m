//
//  BSAPIRequest.m
//  1blankspace
//
//  Created by VenoMKO on 11/30/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import "BSAPIRequest.h"

@implementation BSAPIRequest




#pragma mark -
#pragma mark Common class methods
#pragma mark -




+ (NSDictionary *)convertToWebApiFormat:(NSDictionary *)aData withEndPoint:(BSAPIEndpoint)endpoint
{
    NSDictionary    *format = [BSAPIRequest formatDictionaryForEndpoint:endpoint];
    
    NSMutableDictionary *retVal = [NSMutableDictionary dictionaryWithDictionary:aData];
     
    for (int i = 1; i <= 5; i++) {
        NSString    *key = [NSString stringWithFormat:@"col%d",i];
        
        if ([aData objectForKey:key]) {
            [retVal removeObjectForKey:key];
            [retVal setObject:[aData objectForKey:key] forKey:[format objectForKey:key]];
            
        }
    }
    return retVal;
}

+ (NSDictionary *)displayFormatDictionaryForEndpoint:(BSAPIEndpoint)endpoint
{
    switch (endpoint) {
        default:
        case BSAPIEndpointPerson:
            
            return @{@"col1" : @"First name", @"col2" : @"Last name", @"col3" : @"Email", @"col4" : @"Phone", @"col5" : @"Group:"};
            
            break;
            
        case BSAPIEndpointBusiness:
            
            return @{@"col1" : @"Legal name", @"col2" : @"Trade name", @"col3" : @"Email", @"col4" : @"Phone", @"col5" : @" Business group:"};
            
            break;
    }
}

+ (NSDictionary *)formatDictionaryForEndpoint:(BSAPIEndpoint)endpoint
{
    switch (endpoint) {
        default:
        case BSAPIEndpointPerson:
            
            return @{@"col1" : @"firstname", @"col2" : @"surname", @"col3" : @"email", @"col4" : @"mobile", @"col5" : @"persongroup"};
            
            break;
            
        case BSAPIEndpointBusiness:
            
            return @{@"col1" : @"legalname", @"col2" : @"tradename", @"col3" : @"email", @"col4" : @"phonenumber", @"col5" : @"businessgroup"};
            
            break;
    }
}

+ (NSDictionary *)reversFormatDictionaryForEndpoint:(BSAPIEndpoint)endpoint
{
    switch (endpoint) {
        default:
        case BSAPIEndpointPerson:
            
            return @{ @"firstname" : @"col1", @"surname" : @"col2", @"email" : @"col3", @"mobile" : @"col4"};
            
            break;
            
        case BSAPIEndpointBusiness:
            
            return @{@"legalname" : @"col1", @"tradename" :  @"col2", @"email" : @"col3", @"phonenumber" : @"col4", @"col5" : @"businessgroup"};
            
            break;
    }
}

- (id)init
{
    if ((self = [super init])) {
        _type = BSAPIRequestTypeUnknow;
        [self retain];
    }
    return self;
}

- (id)initWithType:(BSAPIRequestType)aType
{
    if (([self init])) {
        _type = aType;
    }
    return self;
}

- (void)dealloc
{
    if (_connection)
        [_connection release];
    if (_sid)
        [_sid release];
    if (_groupId)
        [_groupId release];
    if (_searchValue)
        [_searchValue release];
    if (_contactInfo)
        [_contactInfo release];
    [super dealloc];
}






#pragma mark -
#pragma mark Public methods
#pragma mark -






- (void)start
{
    NSURLRequest        *request = nil;
    NSDictionary        *error = @{@"code" : @(-1), @"description" : @"Incorrectly formatted request"};
    
    switch (_type) {
            
        case BSAPIRequestTypeGetGroups:
            if (!_sid) {
                break;
            }
            
            request = [self contactGroupsRequest];
            
            break;
        
        case BSAPIRequestTypeGetGroupData:
            
            if (!_sid) {
                break;
            }
            
            request = [self searchRequest];
            
            break;
            
        case BSAPIRequestTypeAddData:
            
            if (!_sid || !_contactInfo) {
                break;
            }
            
            self.contactInfo = [BSAPIRequest convertToWebApiFormat:_contactInfo withEndPoint:_endpoint];
            request = [self addDataRequest];
            
            break;
            
        case BSAPIRequestTypeRemoveData:
            
            if (!_sid || !_contactInfo) {
                break;
            }
            
            request = [self removeDataRequest];
            
            break;
            
        case BSAPIRequestTypeEditData:
            
            if (!_sid || !_contactInfo) {
                break;
            }
            
            _contactInfo = [BSAPIRequest convertToWebApiFormat:_contactInfo withEndPoint:_endpoint];
            request = [self addDataRequest];
            
            break;
            
        case BSAPIRequestTypeAddToGroup:
            
            if (!_sid || !_contactInfo) {
                break;
            }
            
            _contactInfo = [BSAPIRequest convertToWebApiFormat:_contactInfo withEndPoint:_endpoint];
            request = [self addToGroup];
            
            break;
            
        case BSAPIRequestTypeUnknow:
        default:
            break;
    }
    if (!request) {
        if (_delegate && [_delegate respondsToSelector:_didFailSelector]) {
            [_delegate performSelector:_didFailSelector withObject:error];
        } else {
            NSLog(@"Error: %@",error);
        }
        return;
    }
    _receiveData = [[NSMutableData alloc] init];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}


- (void)cancel
{
    if (_connection) {
        [_connection cancel];
        [_connection release];
        _connection = nil;
    }
    [self release];
}





#pragma mark -
#pragma mark Private methods
#pragma mark -
#pragma mark -Request generators-





- (NSURLRequest *)addToGroup
{
    NSMutableURLRequest    *request;
    NSString    *httpBodyString;
    NSString    *subPath = @"contact/?method=";
    
    switch (_endpoint) {
            
        case BSAPIEndpointBusiness:
            subPath = [subPath stringByAppendingFormat:@"CONTACT_BUSINESS_GROUP_MANAGE&sid=%@",_sid];
            httpBodyString = [NSString stringWithFormat:@"contactbusiness=%@&group=%@",[_contactInfo objectForKey:@"id"],[_contactInfo objectForKey:@"group"]];
            break;
            
        case BSAPIEndpointPerson:
        default:
            subPath = [subPath stringByAppendingFormat:@"CONTACT_PERSON_GROUP_MANAGE&sid=%@",_sid];
            httpBodyString = [NSString stringWithFormat:@"contactperson=%@&group=%@",[_contactInfo objectForKey:@"id"],[_contactInfo objectForKey:@"group"]];
            break;
            
    }
    
    request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[BSWebApiUrl stringByAppendingString:subPath]]] autorelease];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSURLRequest *)contactGroupsRequest
{    
    NSMutableURLRequest    *request;
    NSString    *httpBodyString;
    NSString    *subPath;
    
    subPath = @"setup/?method=";
    
    switch (_endpoint) {
        case BSAPIEndpointBusiness:
            subPath = [subPath stringByAppendingString:@"SETUP_CONTACT_BUSINESS_GROUP_SEARCH"];
            break;
            
        case BSAPIEndpointPerson:
        default:
            subPath = [subPath stringByAppendingString:@"SETUP_CONTACT_PERSON_GROUP_SEARCH"];
            break;
    }
    
    request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[BSWebApiUrl stringByAppendingString:subPath]]] autorelease];
    httpBodyString = [NSString stringWithFormat:@"sid=%@",_sid];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSURLRequest *)addDataRequest
{
    NSMutableURLRequest    *request;
    NSString    *httpBodyString = @"";
    NSString    *subPath;
    
    
    
    subPath = @"contact/?method=";
    
    switch (_endpoint) {
        case BSAPIEndpointBusiness:
            subPath = [subPath stringByAppendingString:@"CONTACT_BUSINESS_MANAGE"];
            break;
        
        case BSAPIEndpointPerson:
        default:
            subPath = [subPath stringByAppendingString:@"CONTACT_PERSON_MANAGE"];
            break;
    }
    
    subPath = [subPath stringByAppendingFormat:@"&sid=%@&",_sid];
    
    NSEnumerator *keyEnumerator = [_contactInfo keyEnumerator];
    NSString *key;
    
    while (key = [keyEnumerator nextObject]) {
        httpBodyString = [httpBodyString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,[_contactInfo objectForKey:key]]];
    }
    
    request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[BSWebApiUrl stringByAppendingString:subPath]]] autorelease];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSURLRequest *)removeDataRequest
{
    NSMutableURLRequest    *request;
    NSString    *httpBodyString = [NSString stringWithFormat:@"id=%@",[_contactInfo objectForKey:@"id"]];
    NSString    *subPath;
    
    
    
    subPath = @"contact/?method=";
    
    switch (_endpoint) {
        case BSAPIEndpointBusiness:
            subPath = [subPath stringByAppendingString:@"CONTACT_BUSINESS_MANAGE"];
            break;
            
        case BSAPIEndpointPerson:
        default:
            subPath = [subPath stringByAppendingString:@"CONTACT_PERSON_MANAGE"];
            break;
    }
    
    subPath = [subPath stringByAppendingFormat:@"&sid=%@&remove=1&",_sid];
    
    request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[BSWebApiUrl stringByAppendingString:subPath]]] autorelease];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSURLRequest *)searchRequest
{
    NSMutableURLRequest    *request = nil;
    NSString    *httpBodyString = @"<advancedSearch>";
    NSString    *subPath = @"contact/?method=";
    
    NSDictionary    *formatter = nil;
    
    switch (_endpoint) {
        default:
        case BSAPIEndpointPerson:
            
            formatter = @{@"col1" : @"firstname", @"col2" : @"surname", @"col3" : @"email", @"col4" : @"mobile", @"group" : @"persongroup"};
            
            break;
            
        case BSAPIEndpointBusiness:
            
            formatter = @{@"col1" : @"Legalname", @"col2" : @"Tradename", @"col3" : @"Email", @"col4" : @"PhoneNumber", @"group" : @"BusinessGroup"};
            
            break;
    }
    
    for (int i = 1; i <= 4; i++) {
        
        NSString    *key = [NSString stringWithFormat:@"col%d",i];
        
        httpBodyString = [httpBodyString stringByAppendingFormat:@"<field><name>%@</name></field>",[formatter objectForKey:key]];
    }
    
    if (_groupId && ![_groupId isEqualToString:@"-1"]) {
        httpBodyString = [httpBodyString stringByAppendingFormat:@"<filter><name>%@</name><comparison>EQUAL_TO</comparison><value1>%@</value1></filter>",
                          [formatter objectForKey:@"group"] ,_groupId];
    }
    
    if (_searchValue) {
        httpBodyString = [httpBodyString stringByAppendingFormat:@"<filter><name>quicksearch</name><comparison>TEXT_IS_LIKE</comparison><value1>%@</value1></filter>",
                          _searchValue];
    }
    
    httpBodyString = [httpBodyString stringByAppendingFormat:@"<options><rows>%d</rows></options>",100];
    
    httpBodyString = [httpBodyString stringByAppendingString:@"<summaryField><name>count contactcount</name></summaryField>"];
    
    httpBodyString = [httpBodyString stringByAppendingString:@"</advancedSearch>"];
    
    switch (_endpoint) {
        default:
        case BSAPIEndpointPerson:
            
            subPath = [subPath stringByAppendingFormat:@"CONTACT_PERSON_SEARCH&sid=%@&advanced=1",_sid];
            
            break;
        
        case BSAPIEndpointBusiness:
            
            subPath = [subPath stringByAppendingFormat:@"CONTACT_BUSINESS_SEARCH&sid=%@&advanced=1",_sid];
        
            break;
    }
    
    request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[BSWebApiUrl stringByAppendingString:subPath]]] autorelease];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}





#pragma mark -
#pragma mark -NSURLConnection delegate methods-






-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString        *responseString =[[NSString alloc] initWithBytes:[_receiveData bytes] length:[_receiveData length] encoding:NSUTF8StringEncoding];
    NSDictionary    *response;
    SBJsonParser    *parser = [[SBJsonParser alloc] init];
    
    response = [parser objectWithString:responseString];
    
    [parser release];
    [responseString release];
    
    if ([[response objectForKey:@"status"] isEqualToString:@"ER"] && _delegate && [_delegate respondsToSelector:_didFailSelector]) {
        [_delegate performSelector:_didFailSelector withObject:response];
        [self release];
        return;
    }
    
    if (_type == BSAPIRequestTypeAddData && _contactInfo) {
        
        NSDictionary    *formatter = [BSAPIRequest formatDictionaryForEndpoint:_endpoint];
        NSString    *key = [formatter objectForKey:@"col5"];
        NSNumber    *groupId = [_contactInfo objectForKey:key];
        
        if (groupId && [groupId integerValue] != -1) {
            BSAPIRequest    *chain = [[BSAPIRequest alloc] initWithType:BSAPIRequestTypeAddToGroup];
            
            [chain setSid:_sid];
            [chain setEndpoint:_endpoint];
            [chain setContactInfo:@{@"id" : [response objectForKey:@"id"], @"group" : groupId}];
            [chain setDelegate:_delegate];
            [chain setDidFinishSelector:_didFinishSelector];
            [chain setDidFailSelector:_didFailSelector];
            
            [chain start];
            return;
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:_didFinishSelector]) {
        
        if (![response objectForKey:@"data"] || ![[response objectForKey:@"data"] objectForKey:@"rows"]) {
            [_delegate performSelector:_didFinishSelector withObject:response];
            if (_chainRequest) {
                [_chainRequest start];
            }
            return;
        }
        
        NSDictionary    *formatter = nil;
        
        formatter = [BSAPIRequest reversFormatDictionaryForEndpoint:_endpoint];
        
        NSMutableArray     *formattedRows = [NSMutableArray arrayWithArray:[[response objectForKey:@"data"] objectForKey:@"rows"]];
        NSArray *responseRows = [[response objectForKey:@"data"] objectForKey:@"rows"];
        
        [responseRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSEnumerator    *enumerator = [obj keyEnumerator];
            NSString        *key;
            
            while (key = [enumerator nextObject]) {
                
                if ([formatter objectForKey:key]) {
                    
                    NSMutableDictionary *newRow = [[formattedRows objectAtIndex:idx] mutableCopy];
                    [newRow removeObjectForKey:key];
                    [newRow setObject:[obj objectForKey:key] forKey:[formatter objectForKey:key]];
                    
                    [formattedRows replaceObjectAtIndex:idx withObject:newRow];
                    [newRow release];
                }
                
            }
            
        }];
        
        
        NSMutableDictionary *formattedResponse = [NSMutableDictionary dictionaryWithDictionary:response];
        
        [formattedResponse setObject:@{@"rows" : formattedRows} forKey:@"data"];
        
        [_delegate performSelector:_didFinishSelector withObject:formattedResponse];
    }
    
    if (_chainRequest) {
        [_chainRequest start];
    }
    
    [_receiveData release];
    _receiveData = nil;
    
    [_connection release];
    _connection = nil;
    
    [self release];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSDictionary    *errorDic = @{@"code" : @([error code]), @"description" : [error localizedDescription], @"error-object" : error};
    
    if (_delegate && [_delegate respondsToSelector:_didFailSelector]) {
        [_delegate performSelector:_didFailSelector withObject:errorDic];
    }
    
    [_receiveData release];
    _receiveData = nil;
    
    [_connection release];
    _connection = nil;
    
    [self release];
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

@end
