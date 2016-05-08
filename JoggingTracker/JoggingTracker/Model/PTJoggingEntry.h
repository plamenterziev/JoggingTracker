//
//  PTJoggingEntry.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTSynchronisableObject.h"

@interface PTJoggingEntry : PTSynchronisableObject

@property (nonatomic, strong) NSDate* date;
@property (nonatomic) NSInteger time;
@property (nonatomic) NSInteger distance;

@end
