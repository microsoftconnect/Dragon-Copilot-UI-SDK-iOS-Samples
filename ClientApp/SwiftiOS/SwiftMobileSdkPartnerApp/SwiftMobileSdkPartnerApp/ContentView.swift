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

// MARK: - Configuration Provider

class Configuration: ConfigurationProvider {
    private var partnerId: String
    private var orgId: String
    private var ehrUserId: String
    private var environment: String
    private var authProvider: AuthProvider
    
    init(partnerId: String, orgId: String, ehrUserId: String, environment: String) {
        self.partnerId = partnerId
        self.orgId = orgId
        self.ehrUserId = ehrUserId
        self.environment = environment
        self.authProvider = AuthProvider(orgId: orgId, ehrUserId: ehrUserId)
    }
    
    func getConfiguration() -> DragonCopilotTurnkey.ApplicationConfigProvider {
        let appMetadata = ClientAppInfo(appId: Constants.appId, appVersion: Constants.appVersion, deviceId: Constants.deviceId)
        let serverDetails = ServerInfo(environment: environment, geography: Constants.defaultGeography)
        return ApplicationConfigProvider(
            clientAppInfo: appMetadata,
            serverInfo: serverDetails,
            providerName: "DragonCopilot",
            isInternalClient: false,
            authType: .partnerToken,
            partnerId: self.partnerId,
            customerId: self.orgId
        )
    }
    
    func getAccessTokenProvider() -> any DragonCopilotTurnkey.AppAccessTokenProvider {
        return authProvider
    }
    
    func getUserInfo() -> UserInfo {
        return UserInfo(ehrUserId: self.ehrUserId)
    }
}

// MARK: - Session Provider

class Session: SessionDataProvider {
    var correlationId: String
    
    init(correlationId: String) {
        self.correlationId = correlationId
    }
    
    func getPatientInfo() -> DragonCopilotTurnkey.PatientInfo {
        return PatientInfo(fhirId: UUID().uuidString.lowercased(), firstName: "John", lastName: "Doe", gender: "male")
    }
    
    func getVisitInfo() -> DragonCopilotTurnkey.VisitInfo {
        return VisitInfo(fhirId: UUID().uuidString.lowercased(), correlationId: correlationId)
    }
    
    func setCorrelationId(correlationId: String) {
        self.correlationId = correlationId
    }
}

// MARK: - Auth Provider

class AuthProvider: AppAccessTokenProvider {
    private let tokenService: JWTTokenService
    private var orgId: String
    private var ehrUserId: String
    
    init(orgId: String, ehrUserId: String) {
        self.orgId = orgId
        self.ehrUserId = ehrUserId
        self.tokenService = JWTTokenService()
    }
    
    func accessToken(scopes: [String]?, forceRefresh: Bool, onSuccess: @escaping (ClientTokenProvider) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let token = try await tokenService.fetchAccessToken(orgId: orgId, ehrUserId: ehrUserId)
                onSuccess(ClientTokenProvider(clientToken: ClientToken(token: token)))
            } catch {
                onFailure(error as NSError)
            }
        }
    }
}

// MARK: - View Model

class ContentViewModel: ObservableObject {
    @Published var sessionView: AnyView? = nil
    @Published var turnkeyInitialized: Bool = false
    
    private var appConfigInstance: ApplicationConfig?
    private var configDataProvider: Configuration?
    var correlationId: String = UUID().uuidString.lowercased()
    
    private func shutdownSDK(context: String) {
        print("ContentView: Shutting down SDK with context=\(context)")
        if let instance = appConfigInstance {
            instance.closeSession()
        }
        ApplicationConfig.clearInstance()
        appConfigInstance = nil
        sessionView = nil
        turnkeyInitialized = false
        configDataProvider = nil
    }
    
    func initializeTurnkey(partnerId: String, orgId: String, ehrUserId: String, environment: String) {
        print("ContentView: Initializing Turnkey with partnerId: \(partnerId), orgId: \(orgId)")
        
        let configDataProvider = Configuration(
            partnerId: partnerId,
            orgId: orgId,
            ehrUserId: ehrUserId,
            environment: environment
        )
        self.configDataProvider = configDataProvider
        
        do {
            print("ContentView: Creating new Turnkey instance")
            appConfigInstance = try ApplicationConfig.getInstance(
                dataProvider: configDataProvider,
                delegate: self,
                recordingDelegate: self,
                dictationDelegate: self,
                settingsDelegate: self
            )
            turnkeyInitialized = true
            print("ContentView: Turnkey SDK initialized successfully")
        } catch {
            print("ContentView: Error initializing Turnkey: \(error)")
            appConfigInstance = nil
            turnkeyInitialized = false
            sessionView = nil
        }
    }
    
    func loadEncounter(partnerId: String, orgId: String, ehrUserId: String, environment: String, correlationId: String) {
        if !turnkeyInitialized {
            initializeTurnkey(
                partnerId: partnerId,
                orgId: orgId,
                ehrUserId: ehrUserId,
                environment: environment
            )
        }
        guard let instance = appConfigInstance else {
            print("ContentView: ERROR: Turnkey instance is nil after initialization")
            return
        }
        
        print("ContentView: Loading encounter with CorrelationId: \(correlationId)...")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            do {
                print("ContentView: Opening session...")
                self.sessionView = AnyView(instance.openSession(sessionDataProvider: Session(correlationId: correlationId)))
                print("ContentView: Session view loaded successfully")
            } catch {
                print("ContentView: Error opening session: \(error)")
                self.sessionView = nil
            }
        }
    }
    
    func logout() {
        print("ContentView: Logging out...")
        shutdownSDK(context: "userLogout")
    }
    
    func back() {
        sessionView = nil
    }
}

// MARK: - Delegate Implementations

extension ContentViewModel: AppUiDelegate {
    func webViewLoaded(_ isLoadingDone: Bool) {
        print("ContentView: TurnKey WebView loaded: \(isLoadingDone)")
    }
}

extension ContentViewModel: AppSettingsDelegate {
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

extension ContentViewModel: AppRecordingDelegate {
    func recordingStarted() {
        print("ContentView: Recording started")
    }
    
    func recordingFailed() {
        print("ContentView: Recording failed")
    }
    
    func recordingStopped() {
        print("ContentView: Recording stopped")
    }
    
    func recordingInterrupted(reason: RecordingStopReason) {
        print("ContentView: Recording interrupted: \(reason.rawValue.description)")
    }
    
    func recordingNotification(notification: RecordingProgressNotification) {
        print("ContentView: Recording notification received: \(notification)")
    }
}

extension ContentViewModel: AppDictationDelegate {
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
                                        correlationId: correlationId
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
