//
//  PTSignupViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTSignupViewController.h"
#import "PTLoginController.h"
#import "PTActivityIndicatorHUD.h"
#import "PTUserSignupRequestDetails.h"
#import "PTUserSignupResponseData.h"
#import "PTValidationUtils.h"

#import <UIAlertView+Block.h>

static NSString* const kNibName                 = @"PTSignupViewController";

PTUseLocalizationTableName(@"PTSignupViewController");

@interface PTSignupViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView* outletScrollView;
@property (nonatomic, weak) IBOutlet UITextField* displayNameTextField;
@property (nonatomic, weak) IBOutlet UITextField* emailTextField;
@property (nonatomic, weak) IBOutlet UITextField* passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField* confirmPasswordTextField;

-(IBAction) didTapSignupButton:(UIButton*) sender;
-(void) didTapCloseBarButtonItem:(UIBarButtonItem*) sender;

-(UITextField*) nextEmptyTextField;

-(void) trySignup;
-(BOOL) validateFields;
-(void) hideKeyboard;

@end

@implementation PTSignupViewController

+(instancetype) createFromNib
{
    return [[self alloc] initWithNibName:kNibName bundle:nil];
}

-(UIScrollView*) mainScrollView
{
    return self.outletScrollView;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = PTLS(@"Sign Up");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:PTLS(@"Close")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(didTapCloseBarButtonItem:)];
}

-(UIModalTransitionStyle) modalTransitionStyle
{
    return UIModalTransitionStyleCrossDissolve;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

-(BOOL) textFieldShouldReturn:(UITextField*) textField
{
    UITextField* emptyTextField = [self nextEmptyTextField];
    if(emptyTextField)
    {
        [emptyTextField becomeFirstResponder];
    }
    else
    {
        [self trySignup];
    }
    
    return YES;
}

#pragma mark -
#pragma mark Private methods

-(IBAction) didTapSignupButton:(UIButton*) sender
{
    [self trySignup];
}

-(void) didTapCloseBarButtonItem:(UIBarButtonItem*) sender
{
    [self.delegate signupViewControllerDidRequestToClose:self];
}

-(UITextField*) nextEmptyTextField
{
    UITextField* textField = nil;
    if([self.displayNameTextField.text length] == 0)
    {
        textField = self.displayNameTextField;
    }
    else if([self.emailTextField.text length] == 0)
    {
        textField = self.emailTextField;
    }
    else if([self.passwordTextField.text length] == 0)
    {
        textField = self.passwordTextField;
    }
    else if([self.confirmPasswordTextField.text length] == 0)
    {
        textField = self.confirmPasswordTextField;
    }
    
    return textField;
}

-(void) trySignup
{
    if([self validateFields])
    {
        [self hideKeyboard];
        
        PTUserSignupRequestDetails* requestDetails = [PTUserSignupRequestDetails new];
        requestDetails.displayName = self.displayNameTextField.text;
        requestDetails.email = self.emailTextField.text;
        requestDetails.userName = self.emailTextField.text;
        requestDetails.password = self.passwordTextField.text;
        
        __weak typeof(self) weakSelf = self;
        PTActivityIndicatorHUD* progressHUD = [PTActivityIndicatorHUD new];
        [progressHUD showWithCompletion:^{
            [[PTLoginController sharedController] signupUserWithDetails:requestDetails
                                                                success:^(PTRemoteRequestHandler* requestHandler, PTUser* user)
            {
                [progressHUD hide];
                [weakSelf.delegate signupViewController:self didSignupUser:user];
            }
                                                                failure:^(PTRemoteRequestHandler* requestHandler, NSError* error)
            {
                [progressHUD hide];
                UIAlertView* alertView = [[UIAlertView alloc] initWithMessage:PTLS(@"Unable to singup user. Please try again.\n Error: %@",
                                                                                   [error localizedFailureReason])
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
    
    if(![PTValidationUtils isNameValid:self.displayNameTextField.text])
    {
        invalidTextField = self.displayNameTextField;
        errorDescription = PTLS(@"Please enter valid display name");
    }
    else if(![PTValidationUtils isEmailValid:self.emailTextField.text])
    {
        invalidTextField = self.emailTextField;
        errorDescription = PTLS(@"Please enter valid email address.");
    }
    else if(![PTValidationUtils isPasswordValid:self.passwordTextField.text])
    {
        invalidTextField = self.passwordTextField;
        errorDescription = PTLS(@"Please enter valid password.");
    }
    else if(![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text])
    {
        invalidTextField = self.confirmPasswordTextField;
        errorDescription = PTLS(@"Confirmed password is different from password");
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
    [self.displayNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}

@end
