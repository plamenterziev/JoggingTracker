//
//  ValidationUtilsTests.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PTValidationUtils.h"

@interface ValidationUtilsTests : XCTestCase

@end

@implementation ValidationUtilsTests

-(void) testEmailValidation
{
    NSString* email = nil;
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");
    
    email = @"";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");
    
    email = @"a";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");

    email = @"a@";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");

    email = @"a@a";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");

    email = @"a@a.";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");

    email = @"a.@a";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");

    email = @"@a.a";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");

    email = @"@.";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");

    email = @"a.a@a";
    XCTAssertFalse([PTValidationUtils isEmailValid:email], @"");

    email = @"a@a.a";
    XCTAssertTrue([PTValidationUtils isEmailValid:email], @"");
}

-(void) testPassordValidation
{
    NSString* password = nil;
    XCTAssertFalse([PTValidationUtils isPasswordValid:password], @"");
    
    password = @"";
    XCTAssertFalse([PTValidationUtils isPasswordValid:password], @"");
    
    password = @"   ";
    XCTAssertFalse([PTValidationUtils isPasswordValid:password], @"");
    
    password = @" a";
    XCTAssertTrue([PTValidationUtils isPasswordValid:password], @"");
    
    password = @"a";
    XCTAssertTrue([PTValidationUtils isPasswordValid:password], @"");
    
    password = @"a ";
    XCTAssertTrue([PTValidationUtils isPasswordValid:password], @"");
    
    password = @" a ";
    XCTAssertTrue([PTValidationUtils isPasswordValid:password], @"");
}

-(void) testNameValidation
{
    NSString* name = nil;
    XCTAssertFalse([PTValidationUtils isNameValid:name], @"");
    
    name = @"";
    XCTAssertFalse([PTValidationUtils isNameValid:name], @"");
    
    name = @"   ";
    XCTAssertFalse([PTValidationUtils isNameValid:name], @"");
    
    name = @" a";
    XCTAssertTrue([PTValidationUtils isNameValid:name], @"");
    
    name = @"a";
    XCTAssertTrue([PTValidationUtils isNameValid:name], @"");
    
    name = @"a ";
    XCTAssertTrue([PTValidationUtils isNameValid:name], @"");
    
    name = @" a ";
    XCTAssertTrue([PTValidationUtils isNameValid:name], @"");
}

@end
