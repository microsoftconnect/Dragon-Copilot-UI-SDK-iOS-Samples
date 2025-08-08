# Dragon-Copilot-UI-SDK-iOS-Samples

## Introduction

Dragon Copilot Embedded for Mobile is an SDK that you can integrate with your iOS apps. When initialized, the SDK launches the Dragon Copilot web UI and gives your app access to the full suite of Dragon Copilot features and capabilities.

## SDK Capabilities

This integration enables your users to:
- Perform ambient recording and stream audio to Dragon Copilot for generative AI processing in a reliable and secure manner
- Review AI generated notes and transcripts in the web UI
- Use hands-free dictation of speech to text
- Ask patient-related questions and receive answers from the AI engine

## Sample Applications

This sample repository contains comprehensive examples demonstrating how to integrate the Dragon Copilot UI SDK into third-party iOS mobile applications. The samples showcase different integration approaches and are designed to help developers understand implementation patterns and best practices.

### Available Sample Apps

The repository includes sample applications for two popular development platforms. Each sample demonstrates different aspects of the SDK integration and provides a foundation for developers to build upon.

1. **Swift iOS Native** (`ClientApp/SwiftiOS/`)
   - Native iOS application built with Swift
   - Demonstrates direct framework integration
   - Shows native UI/UX patterns and iOS-specific features

2. **React Native** (`ClientApp/ReactNative/`)
   - Cross-platform React Native implementation
   - Demonstrates bridge integration with native iOS frameworks
   - Shows how to integrate Dragon Copilot in React Native workflows

## Installation - Swift Package Manager (SPM)

Dragon Copilot Embedded for Mobile is delivered as a Swift Package Manager (SPM), making it easy to embed and achieve the desired functionality in your iOS apps. Use the following link to download the package from GitHub:

**Repository URL:** https://github.com/microsoftconnect/Dragon-Copilot-UI-SDK-iOS

### Integration Steps

To import the SDK into your Xcode project as a package dependency:

1. **Open your Xcode project or workspace** (*.xcworkspace)

2. **Add the package dependency:**
   - Go to your project settings and select the **Package Dependencies** tab
   - Select the **+** button to add a new package
   - Enter the URL of the Dragon Copilot Embedded for Mobile repository: 
     ```
     https://github.com/microsoftconnect/Dragon-Copilot-UI-SDK-iOS
     ```
   - Choose the desired branch or version, for example `main` or `release/1.0.0`

3. **Add the framework/library to your target:**
   - Select your app target and open the **General** tab
   - In the **Frameworks, Libraries and Embedded Content** section, check if `DragonCopilotTurnkey.xcframework` is present
   - If not present, select the **+** button and add `DragonCopilotTurnkey.xcframework`

## Tools Directory

The repository contains a `Tools` directory with essential build resources and supplementary files required for proper SDK functionality:

### Build Resources
- **dSYM files** (`Tools/dSYM/`) - Debug symbol files for crash analysis and debugging
- **SBOM files** (`Tools/sbom/`) - Software Bill of Materials for security and compliance tracking

### SpeechKit Resources
The `Tools/DragonMedicalSpeechKit/` directory contains essential runtime resources including localization files for multi-language support, speech recognition model data, UI components for speech correction, and code signing validation files. These resources must be bundled with your application (applicable for ReactNative app) to ensure proper speech recognition functionality and localized user experience. 

### Adding SpeechKit Bundle to Your App

To include the DragonMedicalSpeechKit bundle resources in your application:

1. **Select your App Target** (not the library target)
2. **Navigate to Build Phases** (in the top tabs)
3. **Expand "Copy Bundle Resources"**
4. **Click the "+" button** at the bottom
5. **In the popup dialog:**
   - Find and select the `DragonMedicalSpeechKit.bundle` file from the Tools directory
   - Click "Add"

**Note:** These SpeechKit resources are essential for proper speech recognition functionality and must be included in your app bundle for the SDK to work correctly
