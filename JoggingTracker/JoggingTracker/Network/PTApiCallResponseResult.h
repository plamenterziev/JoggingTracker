//
//  PTApiCallResponseResult.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTApiCallResponseResult : NSObject

@property (nonatomic, strong) NSArray* objects;

+(instancetype) resultWithObjects:(NSArray*) objects;

@end
