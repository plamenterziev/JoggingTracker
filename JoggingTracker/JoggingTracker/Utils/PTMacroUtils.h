//
//  PTMacroUtils.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#define STRINGIFY_IMPL(x) #x
#define STRINGIFY(x) STRINGIFY_IMPL(x)

#define PASTE_IMPL(a, b) a##b
#define PASTE(a, b) PASTE_IMPL(a, b)

#define UNUSED(x) (void)(x)

#define DECLARE_CONSTANT(TYPE, NAME, ...)                                                                   \
    extern TYPE NAME;

#define DEFINE_CONSTANT(TYPE, NAME, VALUE)                                                                  \
    TYPE NAME = VALUE;

#define SAFE_DICTIONARY_VALUE(VALUE) ((VALUE) ? (VALUE) : [NSNull null])