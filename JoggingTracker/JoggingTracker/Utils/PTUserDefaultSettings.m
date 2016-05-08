//
//  PTUserDefaultSettings.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTUserDefaultSettings.h"

#define CREATE_USER_SETTINGS_KEY(PROPERTY_TYPE, PROPERTY_NAME, ...)                                                             \
    NSString* const k ## PROPERTY_NAME ## SettingKey = @"k"@#PROPERTY_NAME@"SettingKeyName";

USER_DEFAULTS_PRIMITIVE_TYPE_SETTINGS(CREATE_USER_SETTINGS_KEY)
USER_DEFAULTS_OBJECT_TYPE_SETTINGS(CREATE_USER_SETTINGS_KEY)

#define CREATE_PRIMITIVE_TYPE_DEFAULT_KEY_VALUE(PROPERTY_TYPE, PROPERTY_NAME, DEFAULT_VALUE)                                    \
    @(DEFAULT_VALUE), k ## PROPERTY_NAME ## SettingKey,

#define CREATE_OBJECT_TYPE_DEFAULT_KEY_VALUE(PROPERTY_TYPE, PROPERTY_NAME, DEFAULT_VALUE)                                       \
    DEFAULT_VALUE, k ## PROPERTY_NAME ## SettingKey,

#define DEFINE_PRIMITIVE_TYPE_PROPERTY(PROPERTY_TYPE, PROPERTY_NAME, ...)                                                       \
    -(void) set ## PROPERTY_NAME:(PROPERTY_TYPE) value                                                                          \
    {                                                                                                                           \
        [[NSUserDefaults standardUserDefaults] helper_set ## PROPERTY_TYPE:value forKey:k ## PROPERTY_NAME ## SettingKey];      \
        [[NSUserDefaults standardUserDefaults] synchronize];                                                                    \
    }                                                                                                                           \
    -(PROPERTY_TYPE) PROPERTY_NAME                                                                                              \
    {                                                                                                                           \
        return [[NSUserDefaults standardUserDefaults] helper_ ## PROPERTY_TYPE ## ForKey:k ## PROPERTY_NAME ## SettingKey];     \
    }

#define DEFINE_OBJECT_TYPE_PROPERTY(PROPERTY_TYPE, PROPERTY_NAME, ...)                                                          \
    -(void) set ## PROPERTY_NAME:(PROPERTY_TYPE) value                                                                          \
    {                                                                                                                           \
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:k ## PROPERTY_NAME ## SettingKey];                        \
        [[NSUserDefaults standardUserDefaults] synchronize];                                                                    \
    }                                                                                                                           \
    -(PROPERTY_TYPE) PROPERTY_NAME                                                                                              \
    {                                                                                                                           \
        return [[NSUserDefaults standardUserDefaults] objectForKey:k ## PROPERTY_NAME ## SettingKey];                           \
    }

@interface NSUserDefaults (Helper)

-(void) helper_setBOOL:(BOOL) value forKey:(NSString*) defaultName;
-(BOOL) helper_BOOLForKey:(NSString*) defaultName;

@end

@implementation NSUserDefaults (Helper)

-(void) helper_setBOOL:(BOOL) value forKey:(NSString*) defaultName
{
    [self setBool:value forKey:defaultName];
}

-(BOOL) helper_BOOLForKey:(NSString*) defaultName
{
    return [self boolForKey:defaultName];
}

@end

@implementation PTUserDefaultsSettings

static PTUserDefaultsSettings* theSettings = nil;

+(instancetype) sharedSettings
{
    if(!theSettings)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            theSettings = [PTUserDefaultsSettings new];
        });
    }
    
    return theSettings;
}

-(id) init
{
    if((self = [super init]))
    {
        NSDictionary* primitiveTypeSettingsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       USER_DEFAULTS_PRIMITIVE_TYPE_SETTINGS(CREATE_PRIMITIVE_TYPE_DEFAULT_KEY_VALUE)
                                                       USER_DEFAULTS_OBJECT_TYPE_SETTINGS(CREATE_OBJECT_TYPE_DEFAULT_KEY_VALUE)
                                                       nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:primitiveTypeSettingsDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return self;
}

USER_DEFAULTS_PRIMITIVE_TYPE_SETTINGS(DEFINE_PRIMITIVE_TYPE_PROPERTY)
USER_DEFAULTS_OBJECT_TYPE_SETTINGS(DEFINE_OBJECT_TYPE_PROPERTY)

@end
