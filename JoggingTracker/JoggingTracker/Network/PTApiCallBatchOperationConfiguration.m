//
//  PTApiCallBatchOperationConfiguration.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallBatchOperationConfiguration.h"

@implementation PTApiCallBatchOperationConfiguration

+(instancetype) configurationForApiCallClass:(Class) apiCallClass
                               payloadObject:(id) payloadObject
                              objectsForPath:(NSArray*) objectsForPath
{
    PTApiCallBatchOperationConfiguration* configuration = [PTApiCallBatchOperationConfiguration new];
    
    configuration.apiCallClass = apiCallClass;
    configuration.payloadObject = payloadObject;
    configuration.objectsForPath = objectsForPath;
    
    return configuration;
}

@end
