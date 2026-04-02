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
  SessionDataProvider,
  ConfigurationProvider,
  AppUiDelegate,
  AppRecordingDelegate,
  AppDictationDelegate,
  AppSettingsDelegate
>
@end

@implementation DRCBridgeModule {
}

@synthesize appConfigApi = _appConfigApi;

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
  return @[];
//  return @[@"onGetTPatient", @"onGetTConfiguration", @"onGetTVisit", @"onGetTUser", @"onAccessToken"];
}

- (ApplicationConfigProvider * _Nonnull)getConfiguration {
  ClientAppInfo *appMetadata = [[ClientAppInfo alloc] initWithAppId:@"Turnkey" appVersion:@"1.0.0" deviceId:@"TurnkeyShell"];
  ServerInfo *serverDetails = [[ServerInfo alloc] initWithEnvironment:@"qa" geography:@"US" cloudInstance:nil];
  
  return [[ApplicationConfigProvider alloc] initWithClientAppInfo:appMetadata serverInfo:serverDetails providerName:@"DragonCopilot" isInternalClient:false authType:AuthTypePartnerToken userInfo:nil partnerId:NULL customerId:NULL ehrInstanceId:nil productId:nil traceId:nil];
}

- (UserInfo * _Nonnull)getUserInfo {
  UserInfo *user = [[UserInfo alloc] initWithId:NULL fhirId:@"" firstName:NULL middleName:NULL lastName:NULL ehrUserId:NULL];
  return user;
}

- (PatientInfo * _Nonnull)getPatientInfo {
  return [[PatientInfo alloc] initWithId:NULL fhirId:[NSUUID UUID].UUIDString firstName:@"John" lastName:@"Doe" middleName:NULL gender:@"male" birthDate:NULL medicalRecordNumber:NULL];
}

- (VisitInfo * _Nonnull)getVisitInfo {
  VisitInfo *visit = [[VisitInfo alloc] initWithId:NULL fhirId:[NSUUID UUID].UUIDString correlationId:[self generateCorrelationId] metadata:NULL reasonForVisit:NULL];
  return visit;
}

- (NSString *)generateCorrelationId {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd-HHmm";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

// Used to initialize the Embedded UI SDK
RCT_EXPORT_METHOD(initEmbeddedUiSdk) {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.appConfigApi = [ApplicationConfig getInstanceWithDataProvider:self 
          delegate:self recordingDelegate:self dictationDelegate:self settingsDelegate:self internalClientDelegate:nil];
  });
}


// Used to open a session
RCT_EXPORT_METHOD(openSession) {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *viewControllerToPresent = [self.appConfigApi openSessionControllerWithSessionDataProvider:self];
    [rootViewController presentViewController:viewControllerToPresent animated:YES completion:nil];
  });
}

// Used to close a session
RCT_EXPORT_METHOD(closeSession) {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.appConfigApi) {
      [self.appConfigApi closeSession];
      NSLog(@"Application Config session closed.");
    } else {
      NSLog(@"Application Config SDK is not initialized. Cannot close session.");
    }
  });
}

// Used to dispose of the Embedded UI SDK
RCT_EXPORT_METHOD(disposeSdk) {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.appConfigApi) {
      [ApplicationConfig clearInstance];
      self.appConfigApi = nil;
      NSLog(@"Application Config SDK disposed.");
    } else {
      NSLog(@"Application Config SDK is not initialized. Cannot dispose.");
    }
  });
}

- (id<AppAccessTokenProvider> _Nonnull)getAccessTokenProvider {
  return  [[AuthProvider alloc] init];
}

#pragma mark - AppUiDelegate

- (void)webViewLoaded:(BOOL)isLoadingDone {
  NSLog(@"[AppUiDelegate] WebView loaded: %@", isLoadingDone ? @"YES" : @"NO");
}

#pragma mark - AppRecordingDelegate

- (void)recordingStarted {
  NSLog(@"[RecordingDelegate] Recording started");
}

- (void)recordingFailed {
  NSLog(@"[RecordingDelegate] Recording failed");
}

- (void)recordingStopped {
  NSLog(@"[RecordingDelegate] Recording stopped");
}

- (void)recordingInterruptedWithReason:(RecordingStopReason)reason {
  NSLog(@"[AppRecordingDelegate] Recording interrupted. Reason: %ld", (long)reason);
}

- (void)recordingNotificationWithNotification:(RecordingProgressNotification)notification {
  NSLog(@"[AppRecordingDelegate] Recording notification. Notification: %ld", (long)notification);
}

#pragma mark - AppDictationDelegate

- (void)dictationStarted {
  NSLog(@"[DictationDelegate] Dictation started");
}

- (void)dictationStopped {
  NSLog(@"[DictationDelegate] Dictation stopped");
}

#pragma mark - AppSettingsDelegate

- (void)isIdleTimerDisabledIsOn:(BOOL)screenOn {
  NSLog(@"[SettingsDelegate] Idle timer disabled: %@", screenOn ? @"YES" : @"NO");
}

- (void)appearanceThemeChangedTo:(NSString *)uiTheme {
  NSLog(@"[SettingsDelegate] Appearance theme changed to: %@", uiTheme);
}

- (void)changeApplicationLanguageTo:(NSString *)languageCode {
  NSLog(@"[SettingsDelegate] Change application language to: %@", languageCode);
}

@end
