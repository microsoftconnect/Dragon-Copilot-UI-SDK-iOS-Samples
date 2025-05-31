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

class ContentViewModel: ObservableObject {
    @Published var sessionView: AnyView? = nil
    @Published var turnkeyInitialized: Bool = false
    
    private var turnkeyInstance: TurnkeyFramework?
    private var correlationId: String = UUID().uuidString.lowercased()
    private var enableSoF: Bool = false
    
    func initializeTurnkey(partnerId: String, orgId: String, ehrUserId: String, environment: String, enableSoF: Bool) {
        print("ContentView: Initializing Turnkey with partnerId: \(partnerId), orgId: \(orgId)")
        
        // Always create a new configuration
        let configDataProvider = Configuration(
            partnerId: partnerId,
            orgId: orgId,
            ehrUserId: ehrUserId,
            environment: environment,
            enableSoF: enableSoF
        )
        
        print("ContentView: Creating new Turnkey instance")
        turnkeyInstance = TurnkeyFramework.initialize(
            dataProvider: configDataProvider,
            delegate: self,
            recordingDelegate: self,
            dictationDelegate: self,
            settingsDelegate: self
        )
        turnkeyInitialized = true
        print("ContentView: Turnkey SDK initialized successfully")
    }
    
    func loadEncounter(partnerId: String, orgId: String, ehrUserId: String, environment: String, correlationId: String, enableSoF: Bool) {
        
        if !turnkeyInitialized {
            initializeTurnkey(
                partnerId: partnerId,
                orgId: orgId,
                ehrUserId: ehrUserId,
                environment: environment,
                enableSoF: enableSoF
            )
        }
        guard let turnkeyInstance = turnkeyInstance else {
            print("ContentView: ERROR: Turnkey instance is nil after initialization")
            return
        }
        
        print("ContentView: Loading encounter with CorrelationId: \(correlationId)...")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("ContentView: Opening session...")
            let sessionProvider = Session(correlationId: correlationId)
            self.sessionView = AnyView(turnkeyInstance.openSession(sessionDataProvider: sessionProvider))
            print("ContentView: Session view loaded successfully")
        }
    }
    
    func back() {
        if let instance = turnkeyInstance {
            print("ContentView: Disposing of Turnkey instance")
            instance.closeSession()
        }
        sessionView = nil
    }
    
    func logout() {
        print("ContentView: Logging out...")
        
        // Properly dispose of the instance
        if let instance = turnkeyInstance {
            print("ContentView: Disposing of Turnkey instance")
            TurnkeyFramework.dispose()
        }
        
        turnkeyInstance = nil
        sessionView = nil
        turnkeyInitialized = false
        print("ContentView: Turnkey SDK de-initialized and instance removed")
    }
}

// MARK: - Delegate Implementations
extension ContentViewModel: TDelegate {
    func isTurnKeyWebViewLoaded(_ isLoadingDone: Bool) {
        print("ContentView: TurnKey WebView loaded: \(isLoadingDone)")
    }
    
    func logout(with logoutType: LogoutReason) {
        print("ContentView: Logout triggered with reason: \(logoutType == .user ? "User" : "Inactivity")")
    }
}

extension ContentViewModel: TSettingsDelegate {
    func appearanceThemeChanged(to uiTheme: String) {
        print("ContentView: Appearance theme changed to: \(uiTheme)")
    }
    
    func isIdleTimerDisabled(isOn screenOn: Bool) {
        print("ContentView: screen on while recording: \(screenOn)")
    }
    
    func changeApplicationLanguage(to languageCode: String) {
        print("ContentView: Application Language Changed: \(String(describing: languageCode))")
    }
}

extension ContentViewModel: TRecordingDelegate {
    func recordingStarted() {
        print("ContentView: Recording started")
    }
    
    func recordingFailed() {
        print("ContentView: Recording failed")
    }
    
    func recordingStopped() {
        print("ContentView: Recording stopped")
    }
    
    func recordingInterrupted(reason: RecordingInterruptionReason) {
        print("ContentView: Recording interrupted: \(reason)")
    }
    
    func recordingNotification(notification: RecordingNotification) {
        print("ContentView: Recording notification received: \(notification)")
    }
}

extension ContentViewModel: TDictationDelegate {
    func dictationStarted() {
        print("ContentView: Dictation started")
    }
    
    func dictationStopped() {
        print("ContentView: Dictation stopped")
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var environment: String = Constants.defaultEnvironment
    @State private var partnerId: String = Constants.partnerId
    @State private var orgId: String = Constants.organizationId
    @State private var ehrUserId: String = Constants.ehrUserId
    @State private var correlationId: String = UUID().uuidString.lowercased()
    @State private var enableSoF: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let sessionView = viewModel.sessionView {
                    sessionView
                        .ignoresSafeArea()
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    viewModel.back()
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 20, weight: .semibold))
                                        Text("Back")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarBackground(Color.black.opacity(0.3), for: .navigationBar)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            TextField("Environment:", text: $environment)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Partner Id:", text: $partnerId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Organization Id:", text: $orgId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("EHR User Id:", text: $ehrUserId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Correlation Id:", text: $correlationId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Toggle("Enable SoF", isOn: $enableSoF)
                            
                            HStack(spacing: 16) {
                                Button("Logout") {
                                    viewModel.logout()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("Load") {
                                    viewModel.loadEncounter(
                                        partnerId: partnerId,
                                        orgId: orgId,
                                        ehrUserId: ehrUserId,
                                        environment: environment,
                                        correlationId: correlationId,
                                        enableSoF: enableSoF
                                    )
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}
