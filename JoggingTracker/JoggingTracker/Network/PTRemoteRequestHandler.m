//
//  PTRemoteRequestHandler.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTRemoteRequestHandler.h"

#import <RestKit.h>

@interface PTRemoteRequestHandler ()

@property (nonatomic, strong) RKObjectRequestOperation* operation;

@end

@implementation PTRemoteRequestHandler

+(instancetype) handlerWithOperation:(RKObjectRequestOperation*) operation
{
    return [[[self class] alloc] initWithOperation:operation];
}

-(instancetype) initWithOperation:(RKObjectRequestOperation*) operarion
{
    if((self = [super init]))
    {
        _operation = operarion;
    }
    
    return self;
}

-(BOOL) isEqual:(id) object
{
    BOOL isEqual = NO;
    if([object isMemberOfClass:[PTRemoteRequestHandler class]])
    {
        isEqual = (((PTRemoteRequestHandler*) object).operation == self.operation);
    }
    
    return isEqual;
}

-(NSUInteger) hash
{
    return [self.operation hash];
}

-(void) cancel
{
    [self.operation cancel];
}

-(NSInteger) HTTPErrorCode
{
    return self.operation.HTTPRequestOperation.response.statusCode;
}

-(BOOL) wasCancelled
{
    return self.operation.isCancelled;
}

@end