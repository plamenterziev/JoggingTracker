//
//  PTMasterViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTMasterViewController.h"
#import "PTLoginViewController.h"
#import "PTLoginController.h"
#import "PTModelController.h"
#import "PTHomeViewController.h"
#import "PTUser.h"
#import "PTNotificator.h"

PTUseLocalizationTableName(@"PTMasterViewController");

@interface PTMasterViewController () <PTLoginViewControllerDelegate,
                                      PTNotificationsObserver>

@property (nonatomic, strong) PTLoginViewController* loginViewController;
@property (nonatomic, strong) PTHomeViewController* homeViewController;
@property (nonatomic, strong) UINavigationController* homeNavigationViewController;

-(void) createLoginViewController;
-(void) createHomeViewControllerWithUser:(PTUser*) user;

@end

@implementation PTMasterViewController

-(void) dealloc
{
    [[PTNotificator sharedNotificator] removeObserver:self];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    UIViewController* childViewController = nil;
    if([[PTLoginController sharedController] isAuthenticated])
    {
        [self createHomeViewControllerWithUser:[PTLoginController sharedController].currentUser];
        childViewController = self.homeNavigationViewController;
        
        [PTModelController sharedController].user = [PTLoginController sharedController].currentUser;
        [[PTModelController sharedController] startSync];
    }
    else
    {
        [self createLoginViewController];
        childViewController = self.loginViewController;
    }
    
    [self setContainedViewController:childViewController];

    [[PTNotificator sharedNotificator] addObserver:self];
}

#pragma mark -
#pragma mark PTLoginViewControllerDelegate methods

-(void) loginViewController:(PTLoginViewController*) sender didSignupUser:(PTUser*) user
{
    [PTModelController sharedController].user = user;
    [[PTModelController sharedController] startSync];
    
    [self createHomeViewControllerWithUser:user];
    [sender dismissViewControllerAnimated:NO completion:nil];
    [self setContainedViewController:self.homeNavigationViewController];
    
    self.loginViewController = nil;
}

-(void) loginViewController:(PTLoginViewController*) sender didLoginUser:(PTUser*) user
{
    [PTModelController sharedController].user = user;
    [[PTModelController sharedController] startSync];
    
    [self createHomeViewControllerWithUser:user];
    [self setContainedViewController:self.homeNavigationViewController];
    
    self.loginViewController = nil;
}

#pragma mark -
#pragma mark PTNotificationsObserver methods

-(void) observeRequestLogout:(id) sender
{
    NSAssert(!self.loginViewController, @"Received logout request on login screen");

    BOOL result = [[PTModelController sharedController] cancelAllOperations];
    if(result)
    {
        result = [[PTModelController sharedController] deleteAllSynchronisableObjects];
    }

    if(result)
    {
        [[PTLoginController sharedController] logout];
    
        [self dismissViewControllerAnimated:NO completion:nil];
        
        [self createLoginViewController];
        [self setContainedViewController:self.loginViewController];
        
        self.homeNavigationViewController = nil;
        self.homeViewController = nil;
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:PTLS(@"Unable to logout. Please try again.")
                                                           delegate:nil
                                                  cancelButtonTitle:PTLS(@"OK")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark Private methods

-(void) createLoginViewController
{
    self.loginViewController = [PTLoginViewController createFromNib];
    self.loginViewController.delegate = self;
}

-(void) createHomeViewControllerWithUser:(PTUser*) user
{
    NSAssert(!self.homeNavigationViewController, @"Home navigation controller is already created");
    NSAssert(!self.homeViewController, @"Home view controller is already created");
    
    self.homeViewController = [PTHomeViewController createFromNib];
    self.homeViewController.user = user;
    
    self.homeNavigationViewController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
}

@end
