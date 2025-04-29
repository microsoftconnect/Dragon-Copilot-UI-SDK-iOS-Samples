This is a new [**React Native**](https://reactnative.dev) project, bootstrapped using [`@react-native-community/cli`](https://github.com/react-native-community/cli).

# Getting Started

>**Note**: Make sure you have completed the [React Native - Environment Setup](https://reactnative.dev/docs/environment-setup) instructions till "Creating a new application" step, before proceeding.

## Step 1: Start the Metro Server

First, you will need to start **Metro**, the JavaScript _bundler_ that ships _with_ React Native.

To start Metro, run the following command from the _root_ of your React Native project:

```bash
# using npm
npm start

# OR using Yarn
yarn start
```

## Step 2: Start your Application

Let Metro Bundler run in its _own_ terminal. Open a _new_ terminal from the _root_ of your React Native project. Run the following command to start your _Android_ or _iOS_ app:

### For Android
Generate debug.keystore and place in <Root>/ClientApp/ReactNative/DRCTurnkeyPartnerApp/android/app/debug.keystore folder
Sample code
```bash
keytool -genkeypair -v -keystore debug.keystore -storepass android -keypass android -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000
```
```bash
# using npm
npm run android

# OR using Yarn
yarn android
```

### For iOS

```bash
# using npm
npm run ios

# OR using Yarn
yarn ios
```

If everything is set up _correctly_, you should see your new app running in your _Android Emulator_ or _iOS Simulator_ shortly provided you have set up your emulator/simulator correctly.

This is one way to run your app — you can also run it directly from within Android Studio and Xcode respectively.

## Step 3: Modifying your App

Now that you have successfully run the app, let's modify it.

1. Open `App.tsx` in your text editor of choice and edit some lines.
2. For **Android**: Press the <kbd>R</kbd> key twice or select **"Reload"** from the **Developer Menu** (<kbd>Ctrl</kbd> + <kbd>M</kbd> (on Window and Linux) or <kbd>Cmd ⌘</kbd> + <kbd>M</kbd> (on macOS)) to see your changes!

   For **iOS**: Hit <kbd>Cmd ⌘</kbd> + <kbd>R</kbd> in your iOS Simulator to reload the app and see your changes!

## Congratulations! :tada:

You've successfully run and modified your React Native App. :partying_face:

### Now what?

- If you want to add this new React Native code to an existing application, check out the [Integration guide](https://reactnative.dev/docs/integration-with-existing-apps).
- If you're curious to learn more about React Native, check out the [Introduction to React Native](https://reactnative.dev/docs/getting-started).

# Troubleshooting

If you can't get this to work, see the [Troubleshooting](https://reactnative.dev/docs/troubleshooting) page.

# Learn More

To learn more about React Native, take a look at the following resources:

- [React Native Website](https://reactnative.dev) - learn more about React Native.
- [Getting Started](https://reactnative.dev/docs/environment-setup) - an **overview** of React Native and how setup your environment.
- [Learn the Basics](https://reactnative.dev/docs/getting-started) - a **guided tour** of the React Native **basics**.
- [Blog](https://reactnative.dev/blog) - read the latest official React Native **Blog** posts.
- [`@facebook/react-native`](https://github.com/facebook/react-native) - the Open Source; GitHub **repository** for React Native.



# Dragon Copilot iOS Turnkey

## Setup Instructions

### Install Required Modules
Ensure you have all the required dependencies installed:
```sh
brew install watchman
brew install cocoapods
brew install nvm
```

### Build Client App
1. Navigate to the project directory:
   ```sh
   cd <root_repo_fodler>/ClientApp/ReactNative
   ```
2. Install dependencies:
   ```sh
   npm install
   ```
3. Navigate to the iOS directory and install CocoaPods:
   ```sh
   cd ios
   pod install
   ```

### Add Embedded Mobile SDK dependencies
1. In Xcode, select the project and navigate to **Package Dependencies**.
2. Add https://github.com/microsoftconnect/Dragon-Copilot-UI-SDK-iOS.git package dependency.

### Configure Authentication
1. Open `AuthProvider.m` file.
2. Modify token generation logic based on your need

### Build and Run the App
1. Select the simulator in Xcode (device does not work).
2. Run the app from Xcode.
3. Open the terminal in the `DRCTurnkeyPartnerApp` directory:
   ```sh
   npm run ios
   ```
4. When prompted, type `i` or run:
   ```sh
   npm start
   ```

## Troubleshooting

### Issue: `/opt/homebrew/opt/asdf/libexec/bin/asdf: No such file or directory`
**Solution:** Delete the `asdf` folder from the user directory and try again.

### Issue: nvm Issues
**Solution:** Run the following command:
   ```sh
   nvm install default
   ```

## Local Versions
Ensure you are using the correct versions:
```sh
npm --version 10.9.2
node --version v23.11.0
```