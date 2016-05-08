//
//  PTValidationUtils.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTValidationUtils.h"

@implementation PTValidationUtils

+(BOOL) isEmailValid:(NSString*) email
{
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([email rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound)
    {
        return NO;
    }
    
    NSRange firstPartRange = [email rangeOfString:@"@"];
    if(firstPartRange.location == NSNotFound)
    {
        return NO;
    }
    
    NSString* userName = [email substringToIndex:firstPartRange.location];
    NSString* domainPart = [email substringFromIndex:(firstPartRange.location + 1)];
    
    if(([[userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) ||
       ([[domainPart stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0))
    {
        return NO;
    }
    
    NSRange domainPartRange = [domainPart rangeOfString:@"."];
    
    if(domainPartRange.location == NSNotFound)
    {
        return NO;
    }
    
    NSString* domain = [domainPart substringToIndex:domainPartRange.location];
    NSString* domainSuffix = [domainPart substringFromIndex:(domainPartRange.location + 1)];
    if(([[domain stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) ||
       ([[domainSuffix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0))
    {
        return NO;
    }
    
    return YES;

}

+(BOOL) isPasswordValid:(NSString*) password
{
    return [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
}

+(BOOL) isNameValid:(NSString*) name
{
    return ([[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0);
}

@end
