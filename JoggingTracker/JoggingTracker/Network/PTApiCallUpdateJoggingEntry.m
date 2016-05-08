//
//  PTApiCallUpdateJoggingEntry.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallUpdateJoggingEntry.h"
#import "PTJoggingEntryRequestDetails.h"
#import "PTObjectsMappingFactory.h"

#import <RestKit.h>

DEFINE_API_CALL_CONFIGURATION(PTApiCallUpdateJoggingEntry,
                              RKRequestMethodPUT,
                              @"classes/JoggingEntry/:serverSideObjectID",
                              nil,
                              RKStatusCodeClassSuccessful)

@implementation PTApiCallUpdateJoggingEntry

+(RKMapping*) objectMapping
{
    return [PTObjectsMappingFactory createResponseMappingForUpdatedRemoteObjectResponseData];
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
