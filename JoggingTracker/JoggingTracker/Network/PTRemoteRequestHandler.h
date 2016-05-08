//
//  PTRemoteRequestHandler.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTApiCallResponseResult.h"

@class RKObjectRequestOperation;

@interface PTRemoteRequestHandler : NSObject

@property (nonatomic, readonly) BOOL wasCancelled;
@property (nonatomic, readonly, strong) RKObjectRequestOperation* operation;

+(instancetype) handlerWithOperation:(RKObjectRequestOperation*) operation;
-(instancetype) initWithOperation:(RKObjectRequestOperation*) operarion;

-(void) cancel;

-(NSInteger) HTTPErrorCode;

@end

typedef void (^PTRemoteRequestSuccessBlock)(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result);
typedef void (^PTRemoteRequestFailureBlock)(PTRemoteRequestHandler* requestHandler, NSError* error);

#define FAILURE_BLOCK(BLOCK)                                                                            \
    ^(RKObjectRequestOperation* operation, NSError* error)                                              \
    {                                                                                                   \
        if((BLOCK))                                                                                     \
        {                                                                                               \
            BLOCK([PTApiCallRequestHandler handlerWithOperation:operation], error);                     \
        }                                                                                               \
    }

