//
//  PTObjectsMappingFactory.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTObjectsMappingFactory.h"
#import "PTUser.h"
#import "PTUserSignupResponseData.h"
#import "PTUserLoginResponseData.h"
#import "PTJoggingEntry.h"
#import "PTCreatedRemoteObjectResponseData.h"
#import "PTUpdatedRemoteObjectResponseData.h"
#import "PTErrorResponseData.h"

#import <RestKit.h>

@implementation PTObjectsMappingFactory

#pragma mark -
#pragma mark Requests mappings

+(RKObjectMapping*) createRequestMappingForUserSignupRequestDetails
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    
    [mapping addAttributeMappingsFromDictionary:@{@"displayName" : @"displayName",
                                                  @"email" : @"email",
                                                  @"userName" : @"username",
                                                  @"password" : @"password"}];
    
    return mapping;
}

+(RKObjectMapping*) createRequestMappingForJoggingEntryRequestDetails
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    
    [mapping addAttributeMappingsFromDictionary:@{@"joggingEntry.clientSideObjectID" : @"clientSideObjectId",
                                                  @"joggingEntry.date" : @"date",
                                                  @"joggingEntry.time" : @"time",
                                                  @"joggingEntry.distance" : @"distance",
                                                  @"isDeleted" : @"isDeleted",
                                                  @"userID" : @"userId"}];
    
    return mapping;
}

+(RKObjectMapping*) createRequestMappingForBatchOperationRequestDetails
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    
    [mapping addAttributeMappingsFromDictionary:@{@"method" : @"method",
                                                  @"path" : @"path",
                                                  @"body" : @"body"}];
    
    return mapping;
}

#pragma mark -
#pragma mark Responses mappings

+(RKObjectMapping*) createResponseMappingForUser
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTUser class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"objectId" : @"userID",
                                                  @"displayName" : @"displayName"}];
    
    
    return mapping;
}

+(RKObjectMapping*) createResponseMappingForUserLoginResponseData
{
    RKObjectMapping* userLoginResultMapping = [RKObjectMapping mappingForClass:[PTUserLoginResponseData class]];
    RKObjectMapping* userMapping = [self createResponseMappingForUser];
    
    [userLoginResultMapping addAttributeMappingsFromDictionary:@{@"sessionToken" : @"sessionToken"}];
    [userLoginResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil
                                                                                           toKeyPath:@"user"
                                                                                         withMapping:userMapping]];
    
    return userLoginResultMapping;
}

+(RKObjectMapping*) createResponseMappingForUserSignupResponseData
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTUserSignupResponseData class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"objectId" : @"userID",
                                                  @"sessionToken" : @"sessionToken"}];
    
    return mapping;
}

+(RKObjectMapping*) createResponseMappingForJoggingEntry
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTJoggingEntry class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"objectId" : @"serverSideObjectID",
                                                  @"clientSideObjectId" : @"clientSideObjectID",
                                                  @"createdAt" : @"dateCreated",
                                                  @"updatedAt" : @"dateUpdated",
                                                  @"date" : @"date",
                                                  @"time" : @"time",
                                                  @"distance" : @"distance",
                                                  @"isDeleted" : @"isDeleted"}];
    
    return mapping;
}

+(RKObjectMapping*) createResponseMappingForCreatedRemoteObjectResponseData
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTCreatedRemoteObjectResponseData class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"objectId" : @"objectID",
                                                  @"createdAt" : @"dateCreated"}];
    
    return mapping;
}

+(RKObjectMapping*) createResponseMappingForUpdatedRemoteObjectResponseData
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTUpdatedRemoteObjectResponseData class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"updatedAt" : @"dateUpdated"}];
    
    return mapping;
}

+(RKObjectMapping*) createResponseMappingForErrorResponseData
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTErrorResponseData class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"code" : @"code",
                                                  @"error" : @"errorDescription"}];
    
    return mapping;
}

+(RKObjectMapping*) createResponseMappingForCreatedRemoteObjectResponseDataInBatchOperation
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTCreatedRemoteObjectResponseData class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"success.objectId" : @"objectID",
                                                  @"success.createdAt" : @"dateCreated"}];
    
    return mapping;
}

+(RKObjectMapping*) createResponseMappingForUpdatedRemoteObjectResponseDataInBatchOperation
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTUpdatedRemoteObjectResponseData class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"success.updatedAt" : @"dateUpdated"}];
    
    return mapping;

}

+(RKObjectMapping*) createResponseMappingForErrorResponseDataInBatchOperation
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PTErrorResponseData class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"error.code" : @"code",
                                                  @"error.error" : @"errorDescription"}];
    
    return mapping;
}

@end
