//
//  JWTTokenService.swift
//  UISDKiOSPartnerApp
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import Foundation
import DragonCopilotTurnkey

class JWTTokenService {
    
    func fetchAccessToken(patnerId: String?, orgId: String?, ehrUserId: String?, enableSoF: Bool? = false) async throws -> (String?, String?, String?) {
        
        if enableSoF ?? false {
            let token = ""
            let issuer = ""
            let launch = ""
            return (token, issuer, launch)
        } else {
            let token = ""
            return (token, nil, nil)
        }
    }
}
