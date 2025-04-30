//
//  AuthProvider.m
//  DRCTurnkeyPartnerApp
// Copyright (c) Microsoft Corporation. All rights reserved.
//

#import "AuthProvider.h"

@implementation AuthProvider

- (void)accessTokenWithScopes:(nullable NSArray<NSString *> *)scopes
                    forceRefresh:(BOOL)forceRefresh
                    onSuccess:(void (^)(TAuthResponse *authResponse))onSuccess
                    onFailure:(void (^)(NSError *error))onFailure {
    
    // Extract the token from the JSON response
    NSString *token = @"";
    if (token) {
      NSLog(@"Token is found in response");
      // Create a TTokenResponse object
      TTokenResponse *tokenResponse = [[TTokenResponse alloc] initWithToken:token];
      TAuthResponse *authResponse = [[TAuthResponse alloc] initWithTokenResponse:tokenResponse];
      onSuccess(authResponse);
    } else {
      NSLog(@"Token not found in response");
      NSError *tokenError = [NSError errorWithDomain:@"AuthProviderErrorDomain" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Token not found in response"}];
      onFailure(tokenError);
    }
}

@end
