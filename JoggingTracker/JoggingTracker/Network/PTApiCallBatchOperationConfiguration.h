//
//  PTApiCallBatchOperationConfiguration.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTApiCallBatchOperationConfiguration : NSObject

@property (nonatomic, strong) Class apiCallClass;
@property (nonatomic, strong) id payloadObject;
@property (nonatomic, strong) NSArray* objectsForPath;

+(instancetype) configurationForApiCallClass:(Class) apiCallClass
                               payloadObject:(id) payloadObject
                              objectsForPath:(NSArray*) objectsForPath;

@end
