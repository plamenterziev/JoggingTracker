//
//  PTApiCallCreateJoggingEntry.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallCreateJoggingEntry.h"
#import "PTJoggingEntryRequestDetails.h"
#import "PTObjectsMappingFactory.h"

#import <RestKit.h>

DEFINE_API_CALL_CONFIGURATION(PTApiCallCreateJoggingEntry,
                              RKRequestMethodPOST,
                              @"classes/JoggingEntry",
                              nil,
                              RKStatusCodeClassSuccessful)

@implementation PTApiCallCreateJoggingEntry

+(RKMapping*) objectMapping
{
    return [PTObjectsMappingFactory createResponseMappingForCreatedRemoteObjectResponseData];
}

+(RKRequestDescriptor*) requestDescriptor
{
    RKObjectMapping* mapping = [PTObjectsMappingFactory createRequestMappingForJoggingEntryRequestDetails];
    
    return [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                 objectClass:[PTJoggingEntryRequestDetails class]
                                                 rootKeyPath:nil
                                                      method:[self requestMethod]];
}

@end
