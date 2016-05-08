//
//  PTApiCallSignupUser.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallSignupUser.h"
#import "PTObjectsMappingFactory.h"
#import "PTUserSignupRequestDetails.h"

#import <RestKit.h>

DEFINE_API_CALL_CONFIGURATION(PTApiCallSignupUser,
                              RKRequestMethodPOST,
                              @"users",
                              nil,
                              RKStatusCodeClassSuccessful)

@implementation PTApiCallSignupUser

+(RKMapping*) objectMapping
{
    return [PTObjectsMappingFactory createResponseMappingForUserSignupResponseData];
}

+(RKRequestDescriptor*) requestDescriptor
{
    RKObjectMapping* mapping = [PTObjectsMappingFactory createRequestMappingForUserSignupRequestDetails];
    
    return [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                 objectClass:[PTUserSignupRequestDetails class]
                                                 rootKeyPath:nil
                                                      method:[self requestMethod]];
}

@end
