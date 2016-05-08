//
//  PTUserDefaultSettings.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

// MACRO format: MACRO(PropertyType, PropertyName, DefaultValue)
#define USER_DEFAULTS_PRIMITIVE_TYPE_SETTINGS(MACRO)

// MACRO format: MACRO(PropertyType, PropertyName, DefaultValue)
#define USER_DEFAULTS_OBJECT_TYPE_SETTINGS(MACRO)                                               \
    MACRO(NSString*, sessionToken, nil)                                                         \
    MACRO(NSDate*, latestSyncedJoggingEntryDateUpdated, nil)

/////////////////////////////////////////////////////////////////////////////////////////////////

#define DECLARE_PRIMITIVE_TYPE_PROPERTY(PROPERTY_TYPE, PROPERTY_NAME, ...)                      \
    @property (nonatomic, setter = set ## PROPERTY_NAME:) PROPERTY_TYPE PROPERTY_NAME;

#define DECLARE_OBJECT_TYPE_PROPERTY(PROPERTY_TYPE, PROPERTY_NAME, ...)                         \
    @property (nonatomic, strong, setter = set ## PROPERTY_NAME:) PROPERTY_TYPE PROPERTY_NAME;

/**
 * User defaults settings that provide better interface over NSUserDefaults
 * Each setting has associated property to user for set/get
 */
@interface PTUserDefaultsSettings : NSObject

+(instancetype) sharedSettings;

USER_DEFAULTS_PRIMITIVE_TYPE_SETTINGS(DECLARE_PRIMITIVE_TYPE_PROPERTY);
USER_DEFAULTS_OBJECT_TYPE_SETTINGS(DECLARE_OBJECT_TYPE_PROPERTY);

@end
