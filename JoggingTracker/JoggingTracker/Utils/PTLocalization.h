//
//  PTLocalization.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

/**
 * Basic support for localization. Define PTUseLocalizationTableName(@"<tableName>"); at the beggining of the file and
 * can use PTLS(format, ...) macro for user visible strings
 */


NSString* PTLocalizedStringImpl(NSString* table, NSString* key, ...);

#define PTUseLocalizationTableName(TABLE_NAME)                              \
    static NSString* const kLocalizationTableName = TABLE_NAME

#define PTLS(KEY, ...)                                                      \
    PTLocalizedStringImpl(kLocalizationTableName, KEY, ##__VA_ARGS__)
