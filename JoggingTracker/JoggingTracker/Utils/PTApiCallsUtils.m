//
//  PTApiCallsUtils.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallsUtils.h"

#import <RestKit.h>

@implementation PTApiCallsUtils

+(RKObjectManager*) createObjectManager
{
    RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kApiBaseURL]];
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    [objectManager.HTTPClient setDefaultHeader:@"X-Parse-Application-Id" value:kParseApplicationID];
    [objectManager.HTTPClient setDefaultHeader:@"X-Parse-REST-API-Key" value:kParseRESTApiKey];
    
    return objectManager;
}

@end
