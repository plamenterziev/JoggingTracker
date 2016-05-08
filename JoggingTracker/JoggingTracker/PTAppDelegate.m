//
//  PTAppDelegate.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTAppDelegate.h"
#import "PTMasterViewController.h"

@implementation PTAppDelegate

-(BOOL) application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    PTMasterViewController* masterViewController = [PTMasterViewController new];
    self.window.rootViewController = masterViewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end
