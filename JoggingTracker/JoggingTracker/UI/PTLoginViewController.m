//
//  PTLoginViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTLoginViewController.h"
#import "PTLoginController.h"
#import "PTUserLoginResponseData.h"
#import "PTValidationUtils.h"
#import "PTRemoteRequestHandler.h"
#import "PTActivityIndicatorHUD.h"
#import "PTSignupViewController.h"

#import <UIAlertView+Block.h>

static NSString* const kNibName                 = @"PTLoginViewController";

PTUseLocalizationTableName(@"PTLoginViewController");

@interface PTLoginViewController () <UITextFieldDelegate,
                                     PTSignupViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView* outletScrollView;
@property (nonatomic, weak) IBOutlet UITextField* emailTextField;
@property (nonatomic, weak) IBOutlet UITextField* passwordTextField;
@property (nonatomic, strong) PTRemoteRequestHandler* loginRequestHandler;

-(IBAction) didTapLoginButton:(UIButton*) sender;
-(IBAction) didTapSignupButton:(UIButton*) sender;

-(void) tryLogin;
-(BOOL) validateFields;
-(void) hideKeyboard;

@end

@implementation PTLoginViewController

+(instancetype) createFromNib
{
    return [[self alloc] initWithNibName:kNibName bundle:nil];
}

-(void) dealloc
{
    [self.loginRequestHandler cancel];
}

-(UIScrollView*) mainScrollView
{
    return self.outletScrollView;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

#pragma mark -
#pragma mark UItextFieldDelegate methods

-(BOOL) textFieldShouldReturn:(UITextField*) textField
{
    if(textField == self.emailTextField && [self.passwordTextField.text length] == 0)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if(textField == self.passwordTextField && [self.emailTextField.text length] == 0)
    {
        [self.emailTextField becomeFirstResponder];
    }
    else
    {
        [self tryLogin];
    }
    
    return YES;
}

#pragma mark -
#pragma mark PTSignupViewControllerDelegate methods

-(void) signupViewController:(PTSignupViewController*) sender didSignupUser:(PTUser*) user
{
    [self.delegate loginViewController:self didSignupUser:user];
}

-(void) signupViewControllerDidRequestToClose:(PTSignupViewController*) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Private methods

-(IBAction) didTapLoginButton:(UIButton*) sender
{
    [self tryLogin];
}

-(IBAction) didTapSignupButton:(UIButton*) sender
{
    PTSignupViewController* signupViewController = [PTSignupViewController createFromNib];
    signupViewController.delegate = self;
    UINavigationController* navigationViewController = [[UINavigationController alloc] initWithRootViewController:signupViewController];
    
    [self presentViewController:navigationViewController animated:YES completion:nil];
}

-(void) tryLogin
{
    if([self validateFields])
    {
        [self hideKeyboard];
        
        __weak typeof(self) weakSelf = self;
        PTActivityIndicatorHUD* progressHUD = [PTActivityIndicatorHUD new];
        [progressHUD showWithCompletion:^{
            self.loginRequestHandler = [[PTLoginController sharedController] loginUserWithEmail:self.emailTextField.text
                                                                                andPassword:self.passwordTextField.text
                                                                                    success:^(PTRemoteRequestHandler* requestHandler, PTUser* user)
            {
                [progressHUD hide];
                [weakSelf.delegate loginViewController:weakSelf didLoginUser:user];
            }
                                                                                    failure:^(PTRemoteRequestHandler* requestHandler, NSError* error)
            {
                [progressHUD hide];
                UIAlertView* alertView = [[UIAlertView alloc] initWithMessage:PTLS(@"Unable to login user. Please try again.\n Error: %@", [error localizedFailureReason])
                                                            cancelButtonTitle:PTLS(@"OK")];
                [alertView show];
            }];
        }];
    }
}

-(BOOL) validateFields
{
    UITextField* invalidTextField = nil;
    NSString* errorDescription = nil;
    
    if(![PTValidationUtils isEmailValid:self.emailTextField.text])
    {
        invalidTextField = self.emailTextField;
        errorDescription = PTLS(@"Please enter valid email address.");
    }
    else if(![PTValidationUtils isPasswordValid:self.passwordTextField.text])
    {
        invalidTextField = self.passwordTextField;
        errorDescription = PTLS(@"Please enter valid password.");
    }
    
    if(errorDescription)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithMessage:errorDescription cancelButtonTitle:PTLS(@"OK")];
        [alertView showUsingBlock:^(UIAlertView* alertView, NSInteger buttonIndex) {
            [invalidTextField becomeFirstResponder];
        }];
    }
    
    return !invalidTextField;
}

-(void) hideKeyboard
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
