//
//  PTCreatedRemoteObjectResponseData.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTCreatedRemoteObjectResponseData : NSObject

@property (nonatomic, strong) NSString* objectID;
@property (nonatomic, strong) NSDate* dateCreated;

@end
