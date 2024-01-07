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
