//
//  PTErrorResponseData.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTErrorResponseData : NSObject

@property (nonatomic) NSInteger code;
@property (nonatomic, strong) NSString* errorDescription;

@end
