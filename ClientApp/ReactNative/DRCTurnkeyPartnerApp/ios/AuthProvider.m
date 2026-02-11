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
    NSString *token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJsYXhtaWdxYTEiLCJodHRwOi8vY3VzdG9tZXJpZC5kcmFnb24uY29tIjoiOWYzODdiYzQtYmYzNi00MDJmLWI2MGEtM2U2ZjFjMWJmMWRlIiwiZXhwIjoxNzcwODUyMzc4LCJpc3MiOiJodHRwczovL3R1cm5rZXktdG9rZW4tZ2VuZXJhdG9yLXAxLmF6dXJld2Vic2l0ZXMubmV0IiwiYXVkIjpbImh0dHBzOi8vc3RyZWFtaW5nLmRheGNvcGlsb3QuY29tIl19.nCiuCOHCmVkhSAJZzSr80XlEhajMzFsH5Nx-1i4VIJbEueEzfKH1X3yi7lAlegomfLggeNmpRZIDPzbdgkcjIDWPKUFDAHix59iBUqV-L7C91qytiTea7i1s3fgA8DVwkHA5IUbVGyJht4C0jbo9k0MSt5Ud4ABWcl1mhCWtqhnrROq37aBre628G43ftJyJZ5ZurJanAiLjmaj3FRqktfJU7AjuYZ7gCK15k0hBZrUAGVb44XTqcYs8blRZ8BjufkXu2gK8Rt6a_RXMnZ0q8mIwtJ_ePv5srlRbmM_wzOWwFKJ5GBoKMum_mhJf84VrKRVllOU43nv3cbfhXCA-SA";
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
