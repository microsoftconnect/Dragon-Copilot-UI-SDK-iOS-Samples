//
//  AuthProvider.m
//  DRCTurnkeyPartnerApp
// Copyright (c) Microsoft Corporation. All rights reserved.
//

#import "AuthProvider.h"

@implementation AuthProvider

- (void)accessTokenWithScopes:(nullable NSArray<NSString *> *)scopes
                    forceRefresh:(BOOL)forceRefresh
                    onSuccess:(void (^)(ClientTokenProvider *tokenProvider))onSuccess
                    onFailure:(void (^)(NSError *error))onFailure {
    
    // Extract the token from the JSON response
    NSString *token = @"";
    if (token) {
      NSLog(@"Token is found in response");
      // Create a ClientToken object
      ClientToken *clientToken = [[ClientToken alloc] initWithToken:token];
      ClientTokenProvider *tokenProvider = [[ClientTokenProvider alloc] initWithClientToken:clientToken clientEntraToken:NULL clientSoFToken:NULL];
      onSuccess(tokenProvider);
    } else {
      NSLog(@"Token not found in response");
      NSError *tokenError = [NSError errorWithDomain:@"AuthProviderErrorDomain" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Token not found in response"}];
      onFailure(tokenError);
    }
}

@end
