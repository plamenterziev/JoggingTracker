//
//  PTActivityIndicatorHUD.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTActivityIndicatorHUD.h"

#import <MBProgressHUD.h>

@interface PTActivityIndicatorHUD ()

@property (nonatomic, strong) MBProgressHUD* hud;

@end

@implementation PTActivityIndicatorHUD

-(void) show
{
    [self showWithCompletion:nil];
}

-(void) hide
{
    [self hideWithCompletion:nil];
}

-(void) showWithCompletion:(void(^)()) completion
{
    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController* topViewController = rootViewController;
    while(topViewController.presentedViewController)
    {
        topViewController = topViewController.presentedViewController;
    }
    
    [self showInView:topViewController.view withCompletion:completion];
}

-(void) hideWithCompletion:(void (^)())completion
{
    [self.hud hide:YES];
    
    if(completion)
    {
        completion();
    }
}

-(void) showInView:(UIView*) view withCompletion:(void(^)()) completion
{
    self.hud = [[MBProgressHUD alloc] initWithView:view];
    self.hud.dimBackground = YES;
    self.hud.removeFromSuperViewOnHide = YES;
    [view addSubview:self.hud];
    [self.hud show:YES];
    
    if(completion)
    {
        completion();
    }
}

-(void) hideInView:(UIView* )view withCompletion:(void(^)()) completion
{
    [MBProgressHUD hideHUDForView:view animated:YES];
    
    if(completion)
    {
        completion();
    }
}

-(void) showInViewController:(UIViewController*) viewController withCompletion:(void(^)()) completion
{
    UIViewController* parentViewController = viewController;
    while(parentViewController.parentViewController)
    {
        parentViewController = parentViewController.parentViewController;
    }
    
    [self showInView:parentViewController.view withCompletion:completion];
}

@end
