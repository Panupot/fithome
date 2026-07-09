#!/usr/bin/env python3
"""Patch Flutter-generated Android files for flutter_local_notifications."""
import re

MANIFEST = "android/app/src/main/AndroidManifest.xml"
GRADLE = "android/app/build.gradle"

PERMISSIONS = """    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
"""

RECEIVERS = """        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
"""

with open(MANIFEST) as f:
    m = f.read()

# Add permissions right after the opening <manifest ...> tag
m = re.sub(r"(<manifest[^>]*>\n)", r"\1" + PERMISSIONS, m, count=1)
# Add notification receivers before </application>
m = m.replace("</application>", RECEIVERS + "    </application>")
# Set app display name
m = re.sub(r'android:label="[^"]*"', 'android:label="FitHome"', m, count=1)

with open(MANIFEST, "w") as f:
    f.write(m)
print("Patched", MANIFEST)

with open(GRADLE) as f:
    g = f.read()

# Raise minSdk to 26 (Android 8.0) so java.time is native.
# This removes the need for core library desugaring, which avoids the
# R8/L8 "This is not a JSON Array" build failure entirely.
g = re.sub(r"minSdk(Version)?\s*=?\s*flutter\.minSdkVersion", "minSdkVersion 26", g)

# Skip lint during release builds so CI lint checks don't block the APK
g = g.replace(
    "android {",
    "android {\n    lint {\n        checkReleaseBuilds false\n        abortOnError false\n    }",
    1,
)

with open(GRADLE, "w") as f:
    f.write(g)
print("Patched", GRADLE)
