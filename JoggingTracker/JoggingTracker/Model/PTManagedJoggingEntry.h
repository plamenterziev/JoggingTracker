//
//  PTManagedJoggingEntry.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PTManagedSynchronisableObject.h"


@interface PTManagedJoggingEntry : PTManagedSynchronisableObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * weekDate;

@end
