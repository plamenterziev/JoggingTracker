//
//  PTContainerViewController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTContainerViewController : UIViewController

@property (nonatomic, strong, readonly) UIView* containerView;

-(void) setContainedViewController:(UIViewController*) controller;

@end
