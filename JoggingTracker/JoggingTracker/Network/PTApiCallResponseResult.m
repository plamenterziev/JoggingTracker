//
//  PTApiCallResponseResult.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallResponseResult.h"

@implementation PTApiCallResponseResult

+(instancetype) resultWithObjects:(NSArray*) objects
{
    PTApiCallResponseResult* result = [self new];
    result.objects = objects;
    
    return result;
}

@end
