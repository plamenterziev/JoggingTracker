//
//  PTCell.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTCell.h"

@implementation PTCell

-(void) reloadData
{
    // Implement in a derived class
}

@end

@implementation PTCell (Configuration)

+(NSString*) nibName
{
    NSAssert(NO, @"Implement in a derived class");
    
    return nil;
}

+(NSString*) reuseIdentifier
{
    NSAssert(NO, @"Implement in a derived class");
    
    return nil;
}

+(CGFloat) height
{
    NSAssert(NO, @"Implement in a derived class");
    
    return 0.0f;
}

@end