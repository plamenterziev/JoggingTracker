//
//  PTConstants.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTMacroUtils.h"

// Enumerate all global constants here. The format is (type, name, value)
#define CONSTANTS(MACRO)                                                                                            \
    MACRO(NSString* const,      kParseApplicationID,            @"V3MrAXLTKlKtxyiPwOHYQWqSHvBlSHS0PJmyjodl")        \
    MACRO(NSString* const,      kParseRESTApiKey,               @"dyke8kP8kiKubdr3qiGqgup4ESKlh18IgEBzjU1m")        \
    MACRO(NSString* const,      kApiBaseURL,                    @"https://api.parse.com/1")                         \
    MACRO(const NSInteger,      kRemoteObjectsFetchLimit,       100)                                                \
    MACRO(const NSInteger,      kUploadObjectsBatchLimit,       50)                                                 \
    MACRO(const NSTimeInterval, kModelSyncFailRetryInterval,    60.0f)                                              \
    MACRO(NSString* const,      kReachabilityHostName,          @"parse.com")

CONSTANTS(DECLARE_CONSTANT)
