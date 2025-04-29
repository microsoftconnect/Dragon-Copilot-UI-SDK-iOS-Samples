//
//  DRCBridgeModule.h
//  DRCTurnkeyPartnerApp
// Copyright (c) Microsoft Corporation. All rights reserved.
//

#ifndef DRCBridgeModule_h
#define DRCBridgeModule_h
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#include <DragonCopilotTurnkey/DragonCopilotTurnkey.h>
#import <DragonCopilotTurnkey/DragonCopilotTurnkey-Swift.h>

@interface DRCBridgeModule : RCTEventEmitter <RCTBridgeModule>

@property (nonatomic, strong) TurnkeyFramework *turnkeySdk;

@end

#endif /* DRCBridgeModule_h */
