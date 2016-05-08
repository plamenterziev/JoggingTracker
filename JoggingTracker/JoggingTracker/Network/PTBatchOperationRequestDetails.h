//
//  PTBatchOperationRequestDetails.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTBatchOperationRequestDetails : NSObject

@property (nonatomic, strong) NSString* method;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSDictionary* body;

@end
