//
//  PTApiCallLoginUser.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallLoginUser.h"
#import "PTObjectsMappingFactory.h"

#import <RestKit.h>

DEFINE_API_CALL_CONFIGURATION(PTApiCallLoginUser,
                              RKRequestMethodGET,
                              @"login",
                              nil,
                              RKStatusCodeClassSuccessful)

@implementation PTApiCallLoginUser

+(RKMapping*) objectMapping
{
    return [PTObjectsMappingFactory createResponseMappingForUserLoginResponseData];
}

@end
