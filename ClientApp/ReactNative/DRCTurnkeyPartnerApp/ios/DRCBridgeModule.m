//
//  DRCBridgeModule.m
//  DRCTurnkeyPartnerApp
// Copyright (c) Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRCBridgeModule.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <DragonCopilotTurnkey/DragonCopilotTurnkey-Swift.h>
#import "AuthProvider.h"

@interface DRCBridgeModule () <
  TSessionDataProvider,
  TConfigurationProvider,
  TDelegate,
  TRecordingDelegate,
  TDictationDelegate,
  TSettingsDelegate
>
@end

@implementation DRCBridgeModule {
}

@synthesize turnkeySdk = _turnkeySdk;

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
  return @[];
//  return @[@"onGetTPatient", @"onGetTConfiguration", @"onGetTVisit", @"onGetTUser", @"onAccessToken"];
}

- (TConfiguration * _Nonnull)getTConfiguration {
  TAppMetadata *appMetadata = [[TAppMetadata alloc] initWithAppId:@"Turnkey"
                                                       appVersion:@"1.0.0"
                                                        deviceId:@"TurnkeyShell"];
  TServerDetails *serverDetails = [[TServerDetails alloc] initWithEnvironment: @"qa" geography:@"US" cloudInstance:NULL];
                                   
                                   
  return [[TConfiguration alloc] initWithAppMetadata: appMetadata serverDetails: serverDetails partnerId: NULL customerId:NULL ehrInstanceId: NULL productId:NULL traceId: NULL];
}

- (TUser * _Nonnull)getTUser {
  TUser *user = [[TUser alloc] initWithId:NULL fhirId:@"" firstName:NULL middleName:NULL lastName:NULL ehrUserId:NULL];
  return user;
}

- (TPatient * _Nonnull)getTPatient {
  return [[TPatient alloc] initWithId:NULL fhirId:@"" firstName:NULL lastName:NULL middleName:NULL gender:NULL birthDate: NULL medicalRecordNumber:NULL];
}

- (TVisit * _Nonnull)getTVisit {
  TVisit *tVisit = [[TVisit alloc] initWithId: NULL fhirId:@"" correlationId:[self generateCorrelationId] metadata:NULL reasonForVisit:NULL];
  return tVisit;
}

- (NSString *)generateCorrelationId {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd-HHmm";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

// Used to initialize the Turnkey SDK
RCT_EXPORT_METHOD(initTurnkeySdk) {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.turnkeySdk = [TurnkeyFramework initializeWithDataProvider:self 
          delegate:self recordingDelegate:self dictationDelegate:self settingsDelegate:self];
  });
}


// Used to open a session
RCT_EXPORT_METHOD(openSession) {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    NSObject *webViewContainer = [self.turnkeySdk openSessionControllerWithSessionDataProvider:self];
    UIViewController *viewControllerToPresent =  (UIViewController *) webViewContainer;
    [rootViewController presentViewController:viewControllerToPresent animated:YES completion:nil];
  });
}

// Used to close a session
RCT_EXPORT_METHOD(closeSession) {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.turnkeySdk) {
      [self.turnkeySdk closeSession];
      NSLog(@"Turnkey session closed.");
    } else {
      NSLog(@"Turnkey SDK is not initialized. Cannot close session.");
    }
  });
}

// Used to dispose of the Turnkey SDK
RCT_EXPORT_METHOD(disposeSdk) {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.turnkeySdk) {
      [TurnkeyFramework dispose];
      self.turnkeySdk = nil;
      NSLog(@"Turnkey SDK disposed.");
    } else {
      NSLog(@"Turnkey SDK is not initialized. Cannot dispose.");
    }
  });
}

- (id<TAccessTokenProvider> _Nonnull)getTAccessTokenProvider {
  return  [[AuthProvider alloc] init];
}

#pragma mark - TDelegate

- (void)isTurnKeyWebViewLoaded:(BOOL)isLoadingDone {
  NSLog(@"[TDelegate] WebView loaded: %@", isLoadingDone ? @"YES" : @"NO");
}

- (void)logoutWith:(LogoutReason)logoutType {
  NSString *reason = logoutType == LogoutReasonUser ? @"User" : @"Inactivity";
  NSLog(@"[TDelegate] Logout occurred. Reason: %@", reason);
}

#pragma mark - TRecordingDelegate

- (void)recordingStarted {
  NSLog(@"[TRecordingDelegate] Recording started");
}

- (void)recordingFailed {
  NSLog(@"[TRecordingDelegate] Recording failed");
}

- (void)recordingStopped {
  NSLog(@"[TRecordingDelegate] Recording stopped");
}

- (void)recordingInterruptedWithReason:(RecordingInterruptionReason)reason {
  NSLog(@"[TRecordingDelegate] Recording interrupted. Reason: %ld", (long)reason);
}

- (void)recordingNotificationWithNotification:(RecordingNotification)notification {
  NSLog(@"[TRecordingDelegate] Recording notification. Notification: %ld", (long)notification);
}

#pragma mark - TDictationDelegate

- (void)dictationStarted {
  NSLog(@"[TDictationDelegate] Dictation started");
}

- (void)dictationStopped {
  NSLog(@"[TDictationDelegate] Dictation stopped");
}

#pragma mark - TSettingsDelegate

- (void)isIdleTimerDisabledIsOn:(BOOL)screenOn {
  NSLog(@"[TSettingsDelegate] Idle timer disabled: %@", screenOn ? @"YES" : @"NO");
}

- (void)appearanceThemeChangedTo:(NSString *)uiTheme {
  NSLog(@"[TSettingsDelegate] Appearance theme changed to: %@", uiTheme);
}

- (void)changeApplicationLanguageTo:(NSString *)languageCode {
  NSLog(@"[TSettingsDelegate] Change application language to: %@", languageCode);
}

@end
