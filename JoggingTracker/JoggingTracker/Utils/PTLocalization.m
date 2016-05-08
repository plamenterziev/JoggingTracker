//
//  PTLocalization.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTLocalization.h"

NSString* PTLocalizedStringImpl(NSString* table, NSString* key, ...)
{
	// Localize the format
	NSString* localizedStringFormat = [[NSBundle mainBundle] localizedStringForKey:key value:key table:table];
	
	va_list args;
    va_start(args, key);
    NSString* string = [[NSString alloc] initWithFormat:localizedStringFormat arguments:args];
    va_end(args);
	
	return string;
}
