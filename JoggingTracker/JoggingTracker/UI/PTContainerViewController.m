//
//  PTContainerViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTContainerViewController.h"
#import "PTUIUtils.h"

@interface PTContainerViewController ()

@property (nonatomic, strong) UIViewController* containedViewController;
@property (nonatomic, strong) UIView* containerView;

@end

@implementation PTContainerViewController

-(UIModalTransitionStyle) modalTransitionStyle
{
    return ((self.containedViewController) ? [self.containedViewController modalTransitionStyle] : [super modalTransitionStyle]);
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return ((self.containedViewController) ? [self.containedViewController preferredStatusBarStyle] : UIStatusBarStyleLightContent);
}

-(BOOL) prefersStatusBarHidden
{
    return ((self.containedViewController) ? [self.containedViewController prefersStatusBarHidden] : NO);
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.containerView = [UIView new];
    [self.view addSubview:self.containerView];
    
    [PTUIUtils addLayoutConstraintsToMatchSuperViewBounds:self.containerView];
    if(self.containedViewController)
    {
        [self addChildViewController:self.containedViewController];
        [self.containerView addSubview:self.containedViewController.view];
        [PTUIUtils addLayoutConstraintsToMatchSuperViewBounds:self.containedViewController.view];
        [self.containedViewController didMoveToParentViewController:self];
    }
}

-(void) setContainedViewController:(UIViewController*) controller
{
    if(_containedViewController && self.isViewLoaded)
    {
        [_containedViewController willMoveToParentViewController:nil];
        [_containedViewController.view removeFromSuperview];
        [_containedViewController removeFromParentViewController];
    }
    
    _containedViewController = controller;
    
    if(self.isViewLoaded)
    {
        [self addChildViewController:_containedViewController];
        [self.containerView addSubview:_containedViewController.view];
        [PTUIUtils addLayoutConstraintsToMatchSuperViewBounds:_containedViewController.view];
        [_containedViewController didMoveToParentViewController:self];
    }
}

@end
