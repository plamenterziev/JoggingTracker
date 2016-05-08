//
//  PTApiCallBatchOperations.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallBatchOperations.h"
#import "PTObjectsMappingFactory.h"
#import "PTBatchOperationRequestDetails.h"
#import "PTApiCallBatchOperationConfiguration.h"

#import <RestKit.h>

DEFINE_API_CALL_CONFIGURATION(PTApiCallBatchOperations,
                              RKRequestMethodPOST,
                              @"batch",
                              nil,
                              RKStatusCodeClassSuccessful)

@implementation PTApiCallBatchOperations

+(RKMapping*) objectMapping
{
    RKDynamicMapping* mapping = [RKDynamicMapping new];
    [mapping setObjectMappingForRepresentationBlock:^RKObjectMapping*(id representation) {
        RKObjectMapping* objectMapping = nil;
        NSDictionary* successBody = representation[@"success"];
        if(successBody)
        {
            if(successBody[@"createdAt"])
            {
                objectMapping = [PTObjectsMappingFactory createResponseMappingForCreatedRemoteObjectResponseDataInBatchOperation];
            }
            else
            {
                objectMapping = [PTObjectsMappingFactory createResponseMappingForUpdatedRemoteObjectResponseDataInBatchOperation];
            }
        }
        else if(representation[@"error"])
        {
            objectMapping = [PTObjectsMappingFactory createResponseMappingForErrorResponseDataInBatchOperation];
        }
        
        return objectMapping;
    }];
    
    return mapping;
}

+(RKRequestDescriptor*) requestDescriptor
{
    RKObjectMapping* mapping = [PTObjectsMappingFactory createRequestMappingForBatchOperationRequestDetails];
    
    return [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                 objectClass:[PTBatchOperationRequestDetails class]
                                                 rootKeyPath:@"requests"
                                                      method:[self requestMethod]];
}

+(id) requestPayloadObjectForConfigurations:(NSArray*) configurations
{
    NSMutableArray* payloadObjects = [NSMutableArray arrayWithCapacity:[configurations count]];
    for(PTApiCallBatchOperationConfiguration* configuration in configurations)
    {
        PTBatchOperationRequestDetails* requestDetails = [PTBatchOperationRequestDetails new];
        requestDetails.method = RKStringFromRequestMethod([configuration.apiCallClass requestMethod]);
        requestDetails.path = [@"/1/" stringByAppendingString:[configuration.apiCallClass pathUsingObjects:configuration.objectsForPath]];
        NSError* error = nil;
        requestDetails.body = [RKObjectParameterization parametersWithObject:configuration.payloadObject
                                                           requestDescriptor:[configuration.apiCallClass requestDescriptor]
                                                                       error:&error];
        if(error)
        {
            NSLog(@"Unable to create batch operation request details for configuration: %@. Error: %@", configuration, error);
        }

        [payloadObjects addObject:requestDetails];
    }
    
    return ([payloadObjects count] > 0 ? payloadObjects : nil);
}

@end
