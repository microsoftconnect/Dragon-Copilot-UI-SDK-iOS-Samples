//
//  ContentView.swift
//  UISDKiOSPartnerApp
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import SwiftUI
import DragonCopilotTurnkey
import Foundation

struct Constants {
    static let partnerId: String = ""
    static let organizationId: String = ""
    static let ehrUserId: String = ""

    static let appId: String = "MobileSdkTestHarness"
    static let appVersion: String = "1.0.0"
    static let deviceId: String = UIDevice.current.model
    
    static let defaultEnvironment: String = "qa"
    static let defaultGeography: String = "US"
}

/// When SMART on FHIR auth is needed, pass additional identitiers, such as partnerId, customerId, productId, ehrUserId
class Configuration: TConfigurationProvider {
    private var partnerId: String
    private var orgId: String
    private var ehrUserId: String
    private var environment: String
    private var enableSoF: Bool?
    
    init(partnerId: String, orgId: String, ehrUserId: String, environment: String, enableSoF: Bool? = false) {
        self.partnerId = partnerId
        self.orgId = orgId
        self.ehrUserId = ehrUserId
        self.environment = environment
        self.enableSoF = enableSoF
    }
    func getTConfiguration() -> DragonCopilotTurnkey.TConfiguration {
        let appMetadata = TAppMetadata(appId: Constants.appId, appVersion: Constants.appVersion, deviceId: Constants.deviceId)
        let serverDetails = TServerDetails(environment: environment, geography: Constants.defaultGeography)
        return TConfiguration(appMetadata: appMetadata, serverDetails: serverDetails, partnerId: self.partnerId, customerId: self.orgId)
        
    }
    func getTAccessTokenProvider() -> any DragonCopilotTurnkey.TAccessTokenProvider {
        return AuthProvider(partnerId: partnerId, orgId: orgId, ehrUserId: ehrUserId, enableSoF: enableSoF)
    }
    func getTUser() -> TUser {
        return TUser(ehrUserId: self.ehrUserId)
    }
}

class Session: TSessionDataProvider {
    var correlationId: String
    
    init(correlationId: String) {
        self.correlationId = correlationId
    }
    func getTPatient() -> DragonCopilotTurnkey.TPatient {
        return TPatient(fhirId: UUID().uuidString.lowercased())
    }
    
    func getTVisit() -> DragonCopilotTurnkey.TVisit {
        return TVisit(fhirId: UUID().uuidString.lowercased(), correlationId: correlationId)
    }
    func setCorrelationId(correlationId: String) {
        self.correlationId = correlationId
    }
}

class AuthProvider: TAccessTokenProvider {
    private let tokenService: JWTTokenService
    private var partnerId: String?
    private var orgId: String?
    private var ehrUserId: String?
    private var enableSoF: Bool?
    
    init(partnerId: String?, orgId: String?, ehrUserId: String?, enableSoF: Bool?) {
        self.partnerId = partnerId
        self.orgId = orgId
        self.ehrUserId = ehrUserId
        self.tokenService = JWTTokenService()
    }
    func accessToken(scopes: [String]?, forceRefresh: Bool, onSuccess: @escaping (TAuthResponse) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let (token, issuer, launch) = try await tokenService.fetchAccessToken(patnerId: partnerId, orgId: orgId, ehrUserId: ehrUserId, enableSoF: enableSoF)
                if enableSoF ?? false{
                    guard let issuer = issuer, let launch = launch else {
                        onFailure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Issuer or launch is nil for SoF"]))
                        return
                    }
                    onSuccess(TAuthResponse(sofTokenResponse: TSoFTokenResponse(token: token, issuer: issuer, launch: launch)))
                } else {
                    guard let token = token else {
                        onFailure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token is empty"]))
                        return
                    }
                    onSuccess(TAuthResponse(tokenResponse: TTokenResponse(token: token)))
                }
            } catch {
                onFailure(error as NSError)
            }
        }
    }
}

struct ContentView: View {
    @State private var path = NavigationPath()
    @State var turnkeyInstance: TurnkeyFramework?
    @State private var environment: String = Constants.defaultEnvironment
    @State private var partnerId: String = Constants.partnerId
    @State private var orgId: String = Constants.organizationId
    @State private var ehrUserId: String = Constants.ehrUserId
    @State private var correlationId: String = UUID().uuidString.lowercased()
    @State private var enableSoF: Bool = false
    @State var turnkeyInitialized: Bool = false
    @State private var buttonClicked: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    TextField("Enviornment:", text: $environment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Partner Id:", text: $partnerId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Organization Id:", text: $orgId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("EHR User Id:", text: $ehrUserId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Correlation Id", text: $correlationId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Toggle("Enable SoF", isOn: $enableSoF)
                    Button("Load Session") {
                        buttonClicked.toggle()
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: $turnkeyInitialized, destination: {
                loadEncounter()
            })
        }
        .onChange(of: buttonClicked) { oldValue, newValue in
            initializeTurnkey()
        }
    }
    
    private func initializeTurnkey() {
        if turnkeyInstance == nil {
            let configDataProvider: Configuration = Configuration(
                partnerId: partnerId,
                orgId: orgId,
                ehrUserId: ehrUserId,
                environment: environment,
                enableSoF: enableSoF
            )
            turnkeyInstance = TurnkeyFramework.initialize(dataProvider: configDataProvider)
        }
        turnkeyInitialized = true
    }
    
    private func loadEncounter() -> some View {
        return turnkeyInstance?.openSession(sessionDataProvider: Session(correlationId: correlationId))
    }
}

#Preview {
    ContentView()
}
