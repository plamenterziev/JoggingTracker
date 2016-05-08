//
//  PTNotificationMacros.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

// http://stackoverflow.com/questions/3046889/optional-parameters-with-c-macros
#define GET_MACRO(_1, _2, _3, _4, NAME, ...) NAME

#define DECLARE_NOTIFY_0(NAME)                                                                                                          \
    -(void) notify##NAME:(id) sender;
#define DECLARE_NOTIFY_1(NAME1, TYPE1)                                                                                                  \
    -(void) notify##NAME1:(TYPE1) arg1 sender:(id) sender;
#define DECLARE_NOTIFY_2(NAME1, TYPE1, NAME2, TYPE2)                                                                                    \
    -(void) notify##NAME1:(TYPE1) arg1 NAME2:(TYPE2) arg2 sender:(id) sender;

#define DECLARE_NOTIFY(...) GET_MACRO(__VA_ARGS__,                                                                                      \
                                      DECLARE_NOTIFY_2,                                                                                 \
                                      ,                                                                                                 \
                                      DECLARE_NOTIFY_1,                                                                                 \
                                      DECLARE_NOTIFY_0)(__VA_ARGS__)

//
#define DEFINE_NOTIFY_0(NAME)                                                                                                           \
    -(void) notify##NAME:(id) sender                                                                                                    \
    {                                                                                                                                   \
        SEL sel = @selector(observe##NAME:);                                                                                            \
        for(id observer in self.observers)                                                                                              \
        {                                                                                                                               \
            if([observer respondsToSelector:sel])                                                                                       \
            {                                                                                                                           \
                [observer observe##NAME:sender];                                                                                        \
            }                                                                                                                           \
        }                                                                                                                               \
    }

#define DEFINE_NOTIFY_1(NAME1, TYPE1)                                                                                                   \
    -(void) notify##NAME1:(TYPE1) arg1 sender:(id) sender                                                                               \
    {                                                                                                                                   \
        SEL sel = @selector(observe##NAME1:sender:);                                                                                    \
        for(id observer in self.observers)                                                                                              \
        {                                                                                                                               \
            if([observer respondsToSelector:sel])                                                                                       \
            {                                                                                                                           \
                [observer observe##NAME1:arg1 sender:sender];                                                                           \
            }                                                                                                                           \
        }                                                                                                                               \
    }

#define DEFINE_NOTIFY_2(NAME1, TYPE1, NAME2, TYPE2)                                                                                     \
    -(void) notify##NAME1:(TYPE1) arg1 NAME2:(TYPE2) arg2 sender:(id) sender                                                            \
    {                                                                                                                                   \
        SEL sel = @selector(observe##NAME1:NAME2:sender:);                                                                              \
        for(id observer in self.observers)                                                                                              \
        {                                                                                                                               \
            if([observer respondsToSelector:sel])                                                                                       \
            {                                                                                                                           \
                [observer observe##NAME1:arg1 NAME2:arg2 sender:sender];                                                                \
            }                                                                                                                           \
        }                                                                                                                               \
    }

#define DEFINE_NOTIFY(...) GET_MACRO(__VA_ARGS__,                                                                                       \
                                     DEFINE_NOTIFY_2,                                                                                   \
                                     ,                                                                                                  \
                                     DEFINE_NOTIFY_1,                                                                                   \
                                     DEFINE_NOTIFY_0)(__VA_ARGS__)

//
#define DECLARE_OBSERVE_0(NAME)                                                                                                         \
    -(void) observe##NAME:(id) sender;
#define DECLARE_OBSERVE_1(NAME1, TYPE1)                                                                                                 \
    -(void) observe##NAME1:(TYPE1) arg1 sender:(id) sender;
#define DECLARE_OBSERVE_2(NAME1, TYPE1, NAME2, TYPE2)                                                                                   \
    -(void) observe##NAME1:(TYPE1) arg1 NAME2:(TYPE2) arg2 sender:(id) sender;

#define DECLARE_OBSERVE(...) GET_MACRO(__VA_ARGS__,                                                                                     \
                                       DECLARE_OBSERVE_2,                                                                               \
                                       ,                                                                                                \
                                       DECLARE_OBSERVE_1,                                                                               \
                                       DECLARE_OBSERVE_0)(__VA_ARGS__)
