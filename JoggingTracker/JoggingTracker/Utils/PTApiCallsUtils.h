//
//  PTApiCallsUtils.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectManager;

/**
 * Utils for different Api calls related stuff
 */
@interface PTApiCallsUtils : NSObject

/**
 * @return Created and configured RestKit object manager to use
 */
+(RKObjectManager*) createObjectManager;

@end
