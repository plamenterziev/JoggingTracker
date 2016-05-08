//
//  PTNotificationsNames.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTMacroUtils.h"
#import "PTModelSyncStatus.h"

@class PTSynchronisableObject;

#define NOTIFICATIONS_NAMES(MACRO)                                  \
    MACRO(RequestLogout)                                            \
    MACRO(ModelSyncDidUpdateStatus, PTModelSyncStatus)              \
    MACRO(DidAddSynchronisableObject, PTSynchronisableObject*)      \
    MACRO(DidDeleteSynchronisableObject, PTSynchronisableObject*)   \
    MACRO(DidUpdateSynchronisableObject, PTSynchronisableObject*)

