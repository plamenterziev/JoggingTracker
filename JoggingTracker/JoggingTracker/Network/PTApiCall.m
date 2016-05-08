//
//  PTApiCall.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCall.h"
#import "PTRemoteRequestHandler.h"
#import "PTApiCallResponseResult.h"

#import <RestKit.h>

@interface PTPathMatcherContainer : NSObject

@property (nonatomic, strong) NSArray* objects;

-(instancetype) initWithObjects:(NSArray*) objects;

@end

@implementation PTPathMatcherContainer

-(instancetype) initWithObjects:(NSArray*) objects
{
    if((self = [super init]))
    {
        _objects = objects;
    }
    
    return self;
}

-(id) valueForKey:(NSString*) key
{
    id value = nil;
    
    for(id object in self.objects)
    {
        @try
        {
            value = [object valueForKey:key];
            break;
        }
        @catch (NSException *exception) {}
    }
    
    return value;
}

@end

@interface PTApiCall ()

-(void) handleSuccess:(RKObjectRequestOperation*) operation mappingResult:(RKMappingResult*) mappingResult;
-(void) handleFailure:(RKObjectRequestOperation*) operation error:(NSError*) error;

@end

@implementation PTApiCall

+(RKResponseDescriptor*) responseDescriptor
{
    RKMapping* objectMapping = [self objectMapping];
    RKResponseDescriptor* responseDescriptor = nil;
    if(objectMapping)
    {
        responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:objectMapping
                                                                          method:[self requestMethod]
                                                                     pathPattern:[self pathPattern]
                                                                         keyPath:[self keyPath]
                                                                     statusCodes:RKStatusCodeIndexSetForClass([self statusCodeClass])];
    }
    else
    {
        NSAssert(NO, @"Implement objectMapping in %@", self);
    }
    
    return responseDescriptor;
}

+(NSString*) pathUsingObjects:(NSArray*) objects;
{
    NSString* path = nil;
    
    if(objects)
    {
        PTPathMatcherContainer* container = [[PTPathMatcherContainer alloc] initWithObjects:objects];
        
        path = RKPathFromPatternWithObject([self pathPattern], container);
    }
    else
    {
        path = [self pathPattern];
    }
    
    return path;
}

-(void) setParameters:(NSDictionary*) parameters
{
    NSMutableDictionary* filteredParameters = nil;
    if(parameters)
    {
        filteredParameters = [NSMutableDictionary dictionaryWithCapacity:[parameters count]];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            if(![obj isKindOfClass:[NSNull class]])
            {
                filteredParameters[key] = obj;
            }
        }];
    }
    
    _parameters = filteredParameters;
}

-(PTRemoteRequestHandler*) executeWithManager:(RKObjectManager*) manager
                             pathUsingObjects:(NSArray*) objects
{
    return [self executeWithManager:manager withPayloadObject:nil pathUsingObjects:objects];
}

-(PTRemoteRequestHandler*) executeWithManager:(RKObjectManager*) manager
                            withPayloadObject:(id) object
                             pathUsingObjects:(NSArray*) objects
{
    NSString* path = [[self class] pathUsingObjects:objects];
    RKObjectRequestOperation* operation = [manager appropriateObjectRequestOperationWithObject:object
                                                                                        method:[[self class] requestMethod]
                                                                                          path:path
                                                                                    parameters:self.parameters];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult)
    {
        [self handleSuccess:operation mappingResult:mappingResult];
    }
                                 failure:^(RKObjectRequestOperation* operation, NSError* error)
    {
        [self handleFailure:operation error:error];
    }];
    
    [manager enqueueObjectRequestOperation:operation];
    
    return [PTRemoteRequestHandler handlerWithOperation:operation];
}

#pragma mark -
#pragma mark Private methods

-(void) handleSuccess:(RKObjectRequestOperation*) operation mappingResult:(RKMappingResult*) mappingResult
{
    if(self.successBlock)
    {
        PTApiCallResponseResult* result = [PTApiCallResponseResult new];
        result.objects = [mappingResult array];
        self.successBlock([PTRemoteRequestHandler handlerWithOperation:operation], result);
    }
}

-(void) handleFailure:(RKObjectRequestOperation*) operation error:(NSError*) error
{
    if(self.failureBlock)
    {
        NSString* errorString = nil;
        NSString* errorJSON = [error localizedRecoverySuggestion];
        if(errorJSON)
        {
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:[errorJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:0
                                                                        error:NULL];
            if(errorDict)
            {
                errorString = errorDict[@"error"];
            }
            else
            {
                errorString = errorJSON;
            }
        }
        if(!errorString)
        {
            errorString = [error localizedDescription];
        }
        
        NSMutableDictionary* errorUserInfo = [[error userInfo] mutableCopy];
        if(errorString)
        {
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = errorString;
        }
        
        self.failureBlock([PTRemoteRequestHandler handlerWithOperation:operation],
                          [NSError errorWithDomain:[error domain]
                                              code:[error code]
                                          userInfo:errorUserInfo]);
    }
}

@end

@implementation PTApiCall (Subclassing)

+(RKMapping*) objectMapping
{
    NSAssert(NO, @"Implement in a derived class");
    return nil;
}

+(RKRequestDescriptor*) requestDescriptor
{
    // Implement in a derived class if need request desctiprior
    return nil;
}

@end
