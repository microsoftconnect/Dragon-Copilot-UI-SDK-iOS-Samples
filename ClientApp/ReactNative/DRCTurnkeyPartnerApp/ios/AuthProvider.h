//
//  AuthProvider.h
//  DRCTurnkeyPartnerApp
// Copyright (c) Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DragonCopilotTurnkey/DragonCopilotTurnkey-Swift.h>
NS_ASSUME_NONNULL_BEGIN

@interface AuthProvider : NSObject <TAccessTokenProvider>

/// Retrieves an access token for authentication.
/// - Parameters:
///   - scopes: Optional array of scopes for token generation.
///   - forceRefresh: A boolean indicating whether to forcefully refresh the token, ignoring any cached token.
///   - onSuccess: The callback that returns a TAuthResponse object if the token is successfully retrieved.
///   - onFailure: The callback that returns an NSError object if token retrieval fails.
- (void)accessTokenWithScope:(nullable NSArray<NSString *> *)scopes
                    forceRefresh:(BOOL)forceRefresh
                    onSuccess:(void (^)(TAuthResponse *authResponse))onSuccess
                    onFailure:(void (^)(NSError *error))onFailure;

@end

NS_ASSUME_NONNULL_END
