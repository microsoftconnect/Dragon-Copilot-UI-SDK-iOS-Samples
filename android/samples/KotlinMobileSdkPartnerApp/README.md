# Kotlin Mobile SDK Partner App

A sample Android application demonstrating integration with the Dragon Copilot Mobile SDK (Embedded UI).

---

## Prerequisites

- **Android Studio** (latest stable version recommended)
- **JDK 17** or higher
- A valid **Organization ID**, **User ID**, and **Partner ID** provided by your Dragon Copilot onboarding team

---

## Getting Started

### 1. Open the Project in Android Studio

1. Launch **Android Studio**.
2. Select **File → Open**.
3. Navigate to and select the `KotlinMobileSdkPartnerApp` folder:
   ```
   Dragon-Copilot-Mobile-SDK-Samples/android/samples/KotlinMobileSdkPartnerApp
   ```
4. Click **OK** and wait for the Gradle sync to complete.

### 2. Configure Your Credentials

Open the file:

```
app/src/main/java/com/microsoft/dragoncopilot/sampleapp/MainActivity.kt
```

Locate the `companion object` block inside the `MainActivity` class:

```kotlin
companion object {
    const val ORG_ID = "" // add your orgId or customerId
    const val USER_ID = "" // add your userId
    const val PARTNER_ID = "" // add your partnerId
}
```

Replace the empty strings with your actual values:

| Constant     | Description                                                 |
|--------------|-------------------------------------------------------------|
| `ORG_ID`     | Your organization / customer ID provided during onboarding. |
| `USER_ID`    | Your user ID.                                               |
| `PARTNER_ID` | Your partner ID.                                            |

**Example:**

```kotlin
companion object {
    const val ORG_ID = "my-org-123"
    const val USER_ID = "user-456"
    const val PARTNER_ID = "partner-789"
}
```

> ⚠️ **Do not commit real credentials to source control.** Consider using `local.properties` or environment variables for sensitive values.

### 3. Update the Embedded UI SDK Version

The SDK version is managed in the Gradle version catalog file:

```
gradle/libs.versions.toml
```

You can find all available versions on [Maven Central](https://central.sonatype.com/artifact/com.microsoft.dragoncopilot/embedded-ui/2.3.1/versions).

Find the `embedded-ui` version entry under `[versions]`:

```toml
[versions]
# ...
embedded-ui = "2.3.1"
```

Change `"2.3.1"` to the desired version:

```toml
embedded-ui = "<NEW_VERSION>"
```

After updating, sync the project by clicking **"Sync Now"** in the notification bar that appears in Android Studio, or via **File → Sync Project with Gradle Files**.

### 4. Build & Run

1. Connect an Android device or start an emulator.
2. Select the **app** run configuration.
3. Click **Run ▶** (or press `Shift + F10`).

---

## Project Structure

```
KotlinMobileSdkPartnerApp/
├── app/
│   ├── build.gradle.kts          # App-level Gradle build script
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/.../sampleapp/
│       │   ├── MainActivity.kt   # Main entry point – configure IDs here
│       │   └── ...
│       └── res/
├── gradle/
│   └── libs.versions.toml        # Version catalog – update SDK version here
├── build.gradle.kts               # Project-level Gradle build script
└── settings.gradle.kts
```

---

## Troubleshooting

| Issue                       | Solution                                                           |
|-----------------------------|--------------------------------------------------------------------|
| Gradle sync fails           | Ensure you have internet access and the correct repository URLs.   |
| `ORG_ID` / `USER_ID` errors | Verify you have replaced the empty strings with valid credentials. |
| SDK version not found       | Confirm the version exists in the configured Maven repository.     |

---

## License

Refer to the license file in the root of the repository for details.

