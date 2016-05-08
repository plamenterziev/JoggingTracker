//
//  PTManagedUser.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PTManagedUser : NSManagedObject

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * displayName;

@end
