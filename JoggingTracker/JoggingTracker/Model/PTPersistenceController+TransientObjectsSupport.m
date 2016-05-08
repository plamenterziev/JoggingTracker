//
//  PTPersistenceController+TransientObjectsSupport.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTPersistenceController+TransientObjectsSupport.h"
#import "PTManagedUser.h"
#import "PTUser.h"

@implementation PTPersistenceController (TransientObjectsSupport)

-(PTUser*) createUserFromManagedUser:(PTManagedUser*) managedUser
{
    PTUser* user = [PTUser new];
    
    user.userID = managedUser.userID;
    user.displayName = managedUser.displayName;
    
    return user;
}

-(void) updateManagedUser:(PTManagedUser*) managedUser fromUser:(PTUser*) user
{
    managedUser.userID = user.userID;
    managedUser.displayName = user.displayName;
}

@end
