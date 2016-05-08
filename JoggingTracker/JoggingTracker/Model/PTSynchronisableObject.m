//
//  PTSynchronisableObject.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTSynchronisableObject.h"
#import "PTManagedSynchronisableObject.h"

@implementation PTSynchronisableObject

-(id) copyWithZone:(NSZone*) zone
{
    PTSynchronisableObject* copy = [[self class] new];
    
    copy.serverSideObjectID = [self.serverSideObjectID copy];
    copy.clientSideObjectID = [self.clientSideObjectID copy];
    copy.dateCreated = [self.dateCreated copy];
    copy.dateUpdated = [self.dateUpdated copy];
    
    return copy;
}

-(instancetype) initWithManagedObject:(PTManagedSynchronisableObject*) managedObject
{
    if((self = [super init]))
    {
        self.serverSideObjectID = managedObject.serverSideObjectID;
        self.clientSideObjectID = managedObject.clientSideObjectID;
        self.dateCreated = managedObject.dateCreated;
        self.dateUpdated = managedObject.dateUpdated;
    }
    
    return self;
}

-(void) exportToManagedObject:(PTManagedSynchronisableObject*) managedObject
{
    managedObject.serverSideObjectID = self.serverSideObjectID;
    managedObject.clientSideObjectID = self.clientSideObjectID;
    managedObject.dateCreated = self.dateCreated;
    managedObject.dateUpdated = self.dateUpdated;
}

-(BOOL) isEqualToSynchronisableObject:(PTSynchronisableObject*) otherObject
{
    BOOL isEqual = YES;
    if(![self isMemberOfClass:[otherObject class]])
    {
        isEqual = NO;
    }
    
    if(isEqual)
    {
        if(self.serverSideObjectID && otherObject.serverSideObjectID)
        {
            if(![self.serverSideObjectID isEqualToString:otherObject.serverSideObjectID])
            {
                isEqual = NO;
            }
        }
        else if(![self.clientSideObjectID isEqualToString:otherObject.clientSideObjectID])
        {
            isEqual = NO;
        }
    }
    
    return isEqual;
}

@end
