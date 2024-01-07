# App_distribution_with_dart_define
This repo contain  a streamlined workflow for Flutter app deployment, combining the power of Dart defines, customized build configurations, and automated Telegram sharing.


# Command-Line Magic: No Third-Party Packages - Automating Flutter Builds with - dart-define and Telegram Sharing

## Introduction

In the ever-evolving landscape of mobile app development, efficiency is key. In this article, we'll explore a streamlined workflow for Flutter app deployment, combining the power of Dart defines, customized build configurations, and automated Telegram sharing.

## Usecase

In the fast-paced world of mobile app development, managing multiple Flutter projects can be tricky. As a developer handling several apps simultaneously, I faced a challenge in the deployment process. It involved building each app, manually adjusting APK names for project details, and then finding and sharing them with the QA team and clients.

This manual routine proved frustrating and time-consuming, leading to the realization that an automated solution was needed. The goal was clear: create a straightforward workflow initiated with a single command. This workflow would automate the entire process, from building the app to renaming APKs and sharing them with QA teams and clients.

## Objectives 

1. **Setting up Dart Defines for Flavors**
   - Open your Flutter project in a code editor and locate the 'android' directory. Inside it, find the 'app' directory.
   - Within the 'app' directory, find the 'build.gradle' file. This is the Gradle build configuration file specific to the Android module of your Flutter project.
   - Inside the 'build.gradle' file, add the provided code snippet.

```gradle
// Add the code snippet here
def localPropertiesFile = rootProject.file('local.properties')

// Define Dart environment variables, initially setting APP_FLAVOR based on the 'mode' property
def dartEnvironmentVariables = [
    APP_FLAVOR: project.hasProperty('mode')
]

// Check if 'dart-defines' property is present
if (project.hasProperty('dart-defines')) {
    dartEnvironmentVariables = dartEnvironmentVariables +
        project.property('dart-defines')
            .split(',')
            .collectEntries { entry ->
                // Decode each entry from base64 and split into key-value pairs
                def pair = new String(entry.decodeBase64(), 'UTF-8').split('=')
                // If the key is 'mode', set APP_FLAVOR property in the project extension
                if (pair.first() == 'mode') {
                  project.ext.APP_FLAVOR = pair.last()
                }
                // Return key-value pair
                [(pair.first()): pair.last()]
            }
}

// (Optional)
// In Flutter for Android builds, there are two folders: 'apk' and 'flutter-apk.'
// As per my knowledge, the APKs in both folders are the same. However, if you prefer using 'flutter-apk,' 
// you can copy the APKs from the 'apk' folder to 'flutter-apk.'
// Please note that the 'flutter-apk' folder may not contain APKs after cleaning the project. 
// You'll see the APKs after the second build But you get modified apk altime in apk/release folder.

def renamePath = { outputFileName ->
    gradle.projectsEvaluated {
        tasks.whenObjectAdded { task ->
            task.doLast {
                // Locate the Flutter APK directory and rename the app-release.apk file
                def flutterApkDir = new File("${project.buildDir}/outputs/flutter-apk/app-release.apk")
                if (flutterApkDir.exists()) {
                    flutterApkDir.renameTo(new File("${project.buildDir}/outputs/flutter-apk/${outputFileName}"))
                }
            }
        }
    }
}

// Define a function to determine the app flavor based on the APP_FLAVOR property
def appFlavor() {
  if (project.hasProperty('APP_FLAVOR')) {
    return "${project.ext.APP_FLAVOR}_"
  }
}
```
4. After that adding this below code snippet in your buildTypes. It will look like this.

```
buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig signingConfigs.debug
            android.applicationVariants.all { variant ->
                variant.outputs.all {
                    if(appFlavor() != null){
                         def appName = variant.getMergedFlavor().applicationId
                         int lastIndex = appName.lastIndexOf('.')
                         def modifiedAppName = lastIndex != -1 ? appName.substring(lastIndex + 1) : appName
                         outputFileName = "${modifiedAppName}_${appFlavor()}${flutterVersionName}(${flutterVersionCode}).apk"
                         // Optional 
                         // renamePath(outputFileName)
                    }
                }
            }
        
        }
    }
```

5. Save the 'build.gradle' file.
6. Now go to the main.dart file and add this below code snippet.

```
const mode = String.fromEnvironment('mode', defaultValue: 'DEV');
  if(mode == "LIVE"){
    // set your production based url
  } else if (mode == "DEV") {
     // set your development based url
  }
```

7. Save the main.dart file.

## Create APKs with Modified Names
Now,  Open your terminal and run the following command to build the APK with Dart define, resulting in a modified app name and flavorType. This command instructs Flutter to build the APK, utilizing the Dart define mode with the value DEV. The build process incorporates the provided Dart define, resulting in a modified app name and flavorType, as per the configurations in your build.gradle file.

```
flutter build apk --dart-define=mode=DEV
```
## Share APKs via Telegram (Optional)
In addition to streamlining your Flutter app deployment process, you have the option to further enhance collaboration by easily sharing the generated APKs with your team and clients through Telegram. This optional step provides a convenient way to distribute and test different app versions in a seamless manner.
Setting up APK Distribution
To enable APK sharing via Telegram, follow these steps:

## 1. Read Configuration from config.json
Ensure you have a config.json file in your project directory with the required Telegram configuration. This file holds the Telegram chat ID and bot token needed for the sharing process.


```
{
  "telegram_chat_id": "",
  "botToken": ""
}
```

To obtain the necessary credentials for Telegram sharing, follow these steps:

## Bot Token:
Go to Telegram and search for BotFather.
Type /start, provide the required information, and BotFather will generate a botToken.
Copy the token and paste it into the config.json file.

## Group Chat ID:
If you want to share APKs automatically, add your bot to the group as an admin with all necessary permissions.
After adding the bot as an admin, send a dummy message in the group.Open the following link in your browser:
```
https://api.telegram.org/bot<yourBotToken>/getUpdates
```
Retrieve the group chat ID from the response. Response will be look like this

```
{
  "ok": true,
  "result": [
    {
      "update_id": 913461151,
      "message": {
        "message_id": 24,
        "from": {
          "id": 1860370691,
          "is_bot": false,
          "first_name": "Abu",
          "last_name": "Sayed",
          "username": "sayed_dev",
          "language_code": "en"
        },
        "chat": {
          "id": -10021154360131,// Copy this chat id
          "title": "TESTING group 2",
          "type": "supergroup"
        },
        "date": 1704629785,
        "text": "hh"
      }
    }
  ]
}
```
Copy the ID and paste it into the config.json file.
Note: This bot will handle APK sharing in the Telegram group. Create the bot once, and it will serve this purpose for a lifetime. Add the bot to your sharing group, grant the necessary permissions, and collect the chat ID.

## 2. Add Telegram Sharing Script
Integrate the following Dart script into your Flutter project. This script reads the Telegram configuration from config.json, locates the latest APK in the build directory, and sends it to your Telegram group.


```
import 'dart:convert';
import 'dart:io';

void main() {

// Read Telegram configuration from config.json
String constantsFileContent =
File("../config.json").readAsStringSync();
Map<String, dynamic> constants = jsonDecode(constantsFileContent);
// Check if Telegram chat ID and bot token are provided
if (constants['telegram_chat_id'].toString().isEmpty ||
constants['botToken'].toString().isEmpty) {
print(
'Please check config.json file. Maybe the Telegram chat ID and BotToken are missing.');

exit(0);

}
print("Sending APK to Telegram initiating....");
// Path to the directory containing APKs
String apkDirectory = '../build/app/outputs/apk/release';
// Use the listSync method to get a list of files in the directory
var apkFiles = Directory(apkDirectory).listSync();
// Find the latest APK file
var matchingApk = apkFiles.firstWhere(
(file) => file is File && file.path.contains(".apk"),
);
// Use curl to send the APK to Telegram
var result = Process.runSync(
'curl',
[
'-F',
'chat_id=${constants['telegram_chat_id']}',
'-F',
'document=@${matchingApk.path}',
'https://api.telegram.org/bot${constants['botToken']}/sendDocument',
],
);
// Check the result and handle accordingly
if (result.exitCode == 0) {
print('APK sent to Telegram successfully.');

exit(0);

} else {
print('Failed to send APK to Telegram. Error: ${result.stderr}');
exit(0);
}
}
```
## 3. Run the Telegram Sharing Command
After successfully building your Flutter APK, run the following command in your terminal to initiate the Telegram sharing process.
Note: Go to the lib folder then run this command.

```
dart telegram_sharing_script.dart
```
This command sends the latest APK to your Telegram group, making it easily accessible for your team and clients.
