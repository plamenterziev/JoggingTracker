//
//  PTObjectsMappingFactory.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

/**
 * Factory for all requests and responses mappings
 */
@interface PTObjectsMappingFactory : NSObject

// Requests mappings
+(RKObjectMapping*) createRequestMappingForUserSignupRequestDetails;
+(RKObjectMapping*) createRequestMappingForJoggingEntryRequestDetails;
+(RKObjectMapping*) createRequestMappingForBatchOperationRequestDetails;

// Responses mappings
+(RKObjectMapping*) createResponseMappingForUser;
+(RKObjectMapping*) createResponseMappingForUserLoginResponseData;
+(RKObjectMapping*) createResponseMappingForUserSignupResponseData;
+(RKObjectMapping*) createResponseMappingForJoggingEntry;
+(RKObjectMapping*) createResponseMappingForCreatedRemoteObjectResponseData;
+(RKObjectMapping*) createResponseMappingForUpdatedRemoteObjectResponseData;
+(RKObjectMapping*) createResponseMappingForErrorResponseData;
+(RKObjectMapping*) createResponseMappingForCreatedRemoteObjectResponseDataInBatchOperation;
+(RKObjectMapping*) createResponseMappingForUpdatedRemoteObjectResponseDataInBatchOperation;
+(RKObjectMapping*) createResponseMappingForErrorResponseDataInBatchOperation;

@end
