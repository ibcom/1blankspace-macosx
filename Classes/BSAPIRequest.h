//
//  BSAPIRequest.h
//  1blankspace
//
//  Created by VenoMKO on 11/30/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"

static NSString *const                              BSWebApiUrl = @"https://secure.mydigitalspacelive.com/ondemand/";

// Endpoint type

typedef enum{
    BSAPIEndpointPerson = 0,  // CONTACT_PERSON
    BSAPIEndpointBusiness = 1 // CONTACT_BUSINESS
} BSAPIEndpoint;

// Request type

typedef enum{
    
    BSAPIRequestTypeGetGroups,      // Getting list of groups for current endpoint
    BSAPIRequestTypeGetGroupData,   // Getting a list of data for a selected group
    BSAPIRequestTypeAddData,        // Adding row in a list
    BSAPIRequestTypeRemoveData,     // Removing data from a list
    BSAPIRequestTypeEditData,       // Editing row in a list
    BSAPIRequestTypeAddToGroup,     // Adding a row to a specified group
    BSAPIRequestTypeUnknow          // Error
    
} BSAPIRequestType;


/*!
 
    @class  BSAPIRequest
 
    @abstract
 
        This is a sample class to demonstrate basics.
        BSAPIRequest object allows you to perform asynchronous requests
        to mydigitalstructure webapi providing data to a
        client supplied delegate via didFinish and didFail selectors
 
    @discussion
 
        The interface provides only two methods: start and cancel.
        
        Before starting a request user must setup some propertes like 
        delegate, finish selectors, sid, etc.
 
        BSAPIRequest class doesn't support ARC. If you are using ARC, mark 
        BSAPIRequest.h and BSAPIRequest.m with '-fno-objc-arc' flag
 
    @warning
        
        This is just a sample code. You shouldn't use it in your projects
        'as is'. It was made only to demonstrate basic principles of 
        webapi usage in native OS X programms.
 
 */

@interface BSAPIRequest : NSObject {
    BSAPIRequestType                                _type;
    NSMutableData                                   *_receiveData;
    NSURLConnection                                 *_connection;
}

/*!
 
    @property endpoint
    
    @abstract
 
        Used to define wich type of endpoint should be used. 
        Defaults is BSAPIEndpointPerson
 
 */

@property (assign) BSAPIEndpoint                    endpoint;

/*!
 
    @property delegate
 
    @abstract
 
        didFinish and didFail selectors are called upon this 
        object when a request finishes or fails.
 
 */

@property (assign) id                               delegate;

/*!
 
    @property didFinishSelector
 
    @abstract
 
        This selector is performed when a request successfully finish.
    
    @param (NSDictionary *) response
        
        This parameter is an actual response of the webapi
 
 */

@property (assign) SEL                              didFinishSelector;

/*!
 
    @property didFailSelector
 
    @abstract
 
        This selector is performed when a request failed or webapi sent an error.
 
    @param (NSDictionary *) response
 
        This parameter is an actual response of the webapi. May content error
        description and code.
 
 */

@property (assign) SEL                              didFailSelector;

/*!
 
    @property sid
 
    @abstract
 
        This property represents a uniqe session identifier.
    
    @discussion
 
        Mandatory property
 
 */

@property (retain) NSString                         *sid;

/*!
 
    @property groupId
 
    @abstract
 
        This property represents row's group identidier.
 
    @discussion
 
        This property is used with a search method only.
 
 */

@property (retain) NSString                         *groupId;

/*!
 
    @property searchValue
 
    @abstract
 
        This property represents additional search criteria.
    
    @discussion
 
        This property is used with a search method ony.
 
 */

@property (retain) NSString                         *searchValue;

/*!
 
    @property searchValue
 
    @abstract
 
        contactInfo is used to provide row information(e.g. firstname, email, id, etc.)
 
    @discussion
 
        This a mandatory property for requests like:
        
        BSAPIRequestTypeAddData
        BSAPIRequestTypeRemoveData
        BSAPIRequestTypeEditData
        BSAPIRequestTypeAddToGroup
 
 */

@property (retain) NSDictionary                     *contactInfo;

/*!
 
    @property chainRequest
 
    @abstract
 
        Used to implement additional request that will be called right after this request finishes.
 
    @discussion
 
        This request is not called if a request failed.
 
 */

@property (retain) BSAPIRequest                     *chainRequest;


/*!
 
    @method         convertToWebApiFormat:withEndPoint:
 
    @abstract
 
                    Converts passed dictionary from in-app format to webapi format
 
    @param
        endpoint    Type of endpoint
 
    @param
        aData       Initial dictionary with in-app format wich will be converted
 
    @result
                    Converted dictionary with webapi keys
 
 */


+ (NSDictionary *)convertToWebApiFormat:(NSDictionary *)aData withEndPoint:(BSAPIEndpoint)endpoint;

/*!
 
    @method         displayFormatDictionaryForEndpoint:
 
    @abstract
 
                    Used to get a dictionary with formats for end-user
 
    @param
        endpoint    Type of endpoint. Used to determine wich fileds will be returned
 
    @result
                    A dictionary with format:
                    
                    "col1" : "Title of the field 1", "col2" : "Title of the field 2"...
 
 */

+ (NSDictionary *)displayFormatDictionaryForEndpoint:(BSAPIEndpoint)endpoint;

/*!
 
    @method         formatDictionaryForEndpoint:
 
    @abstract
 
                    Used to get a dictionary with formats for conversion from in-app to webapi fields
 
    @param
        endpoint    Type of endpoint. Used to determine wich fileds will be returned
 
    @result
                    A dictionary with format:
 
                    "col1" : "Legalname", "col2" : "BusinessGroup"...
 
 */

+ (NSDictionary *)formatDictionaryForEndpoint:(BSAPIEndpoint)endpoint;

/*!
 
    @method         reversFormatDictionaryForEndpoint:
 
    @abstract
 
                    Used to get a dictionary with formats for conversion from webapi to in-app fields
 
    @param
        endpoint    Type of endpoint. Used to determine wich fields will be returned
 
    @result
                    A dictionary with format:
 
                    "Legalname" : "col1", "BusinessGroup" : "col2"...
 
 */

+ (NSDictionary *)reversFormatDictionaryForEndpoint:(BSAPIEndpoint)endpoint;


- (id)initWithType:(BSAPIRequestType)aType;

- (void)start;

- (void)cancel;

@end
