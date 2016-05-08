//
//  PTApiCall.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RKHTTPUtilities.h>

@class RKObjectRequestOperation;
@class RKMapping;
@class RKResponseDescriptor;
@class RKRequestDescriptor;
@class RKObjectManager;
@class PTApiCallResponseResult;
@class PTRemoteRequestHandler;

typedef void (^PTApiCallSuccessBlock)(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result);
typedef void (^PTApiCallFailureBlock)(PTRemoteRequestHandler* requestHandler, NSError* error);

/**
 * Base class for REST API Calls
 */
@interface PTApiCall : NSObject

@property (nonatomic, strong) PTApiCallSuccessBlock successBlock;
@property (nonatomic, strong) PTApiCallFailureBlock failureBlock;
@property (nonatomic, strong) NSDictionary* parameters;

+(RKResponseDescriptor*) responseDescriptor;

+(NSString*) pathUsingObjects:(NSArray*) objects;

-(PTRemoteRequestHandler*) executeWithManager:(RKObjectManager*) manager
                             pathUsingObjects:(NSArray*) objects;

-(PTRemoteRequestHandler*) executeWithManager:(RKObjectManager*) manager
                            withPayloadObject:(id) object
                             pathUsingObjects:(NSArray*) objects;

@end

/**
 * Methods to overwrite in the derived classes
 */
@interface PTApiCall (Subclassing)

+(RKMapping*) objectMapping;
+(RKRequestDescriptor*) requestDescriptor;

@end

@interface PTApiCall (ApiCallConfiguration)

+(RKRequestMethod) requestMethod;
+(NSString*) pathPattern;
+(NSString*) keyPath;
+(RKStatusCodeClass) statusCodeClass;

@end

#define DEFINE_API_CALL_CONFIGURATION(CLASS, REQUEST_METHOD, PATH_PATTERN, KEY_PATH, STATUS_CODE_CLASS)         \
    @implementation CLASS(ApiCallConfiguration)                                                                 \
        +(RKRequestMethod) requestMethod                                                                        \
        {                                                                                                       \
            return REQUEST_METHOD;                                                                              \
        }                                                                                                       \
        +(NSString*) pathPattern                                                                                \
        {                                                                                                       \
            return PATH_PATTERN;                                                                                \
        }                                                                                                       \
        +(NSString*) keyPath                                                                                    \
        {                                                                                                       \
            return KEY_PATH;                                                                                    \
        }                                                                                                       \
        +(RKStatusCodeClass) statusCodeClass                                                                    \
        {                                                                                                       \
            return STATUS_CODE_CLASS;                                                                           \
        }                                                                                                       \
    @end
