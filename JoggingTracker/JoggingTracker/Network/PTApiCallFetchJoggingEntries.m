//
//  PTApiCallFetchJoggingEntries.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTApiCallFetchJoggingEntries.h"
#import "PTJoggingEntry.h"
#import "PTObjectsMappingFactory.h"

#import <RestKit.h>

DEFINE_API_CALL_CONFIGURATION(PTApiCallFetchJoggingEntries,
                              RKRequestMethodGET,
                              @"classes/JoggingEntry",
                              @"results",
                              RKStatusCodeClassSuccessful)

@implementation PTApiCallFetchJoggingEntries

+(RKMapping*) objectMapping
{
    return [PTObjectsMappingFactory createResponseMappingForJoggingEntry];
}

@end
