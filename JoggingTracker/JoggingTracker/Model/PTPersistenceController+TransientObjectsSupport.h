//
//  PTPersistenceController+TransientObjectsSupport.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTPersistenceController.h"

@class PTManagedUser;
@class PTUser;
@class PTManagedJoggingEntry;
@class PTJoggingEntry;
@class PTManagedSynchronisableObject;
@class PTSynchronisableObject;

@interface PTPersistenceController (TransientObjectsSupport)

-(PTUser*) createUserFromManagedUser:(PTManagedUser*) managedUser;
-(void) updateManagedUser:(PTManagedUser*) managedUser fromUser:(PTUser*) user;

@end
