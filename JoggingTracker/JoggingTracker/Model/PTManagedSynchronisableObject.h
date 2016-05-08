//
//  PTManagedSynchronisableObject.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PTManagedSynchronisableObject : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * clientSideObjectID;
@property (nonatomic, retain) NSString * serverSideObjectID;

@end
