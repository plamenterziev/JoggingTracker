//
//  PTSynchronisableObject.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTManagedSynchronisableObject;

@interface PTSynchronisableObject : NSObject <NSCopying>

@property (nonatomic, strong) NSString* serverSideObjectID;
@property (nonatomic, strong) NSString* clientSideObjectID;
@property (nonatomic, strong) NSDate* dateCreated;
@property (nonatomic, strong) NSDate* dateUpdated;
@property (nonatomic) BOOL isDeleted;

-(instancetype) initWithManagedObject:(PTManagedSynchronisableObject*) managedObject;
-(void) exportToManagedObject:(PTManagedSynchronisableObject*) managedObject;

-(BOOL) isEqualToSynchronisableObject:(PTSynchronisableObject*) otherObject;

@end
