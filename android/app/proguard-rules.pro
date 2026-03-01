# ML Kit Text Recognition Proguard Rules
# The plugin references these classes even if you don't add the extra language pods/dependencies.
# Tell R8 to ignore missing classes as we are likely not using those languages.

-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# General ML Kit keep rules
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Timezone Support (Required for zonedSchedule)
-keep class com.timezone.timezone.** { *; }
-dontwarn com.timezone.timezone.**

# Ensure TZDB data is not removed
-keep class com.timezone.data.** { *; }

# Prevent Gson from being stripped, required by flutter_local_notifications
# to decode scheduled notifications from the AlarmManager Intent JSON payload.
# Without this, the app will crash at the exact exact time the alarm fires.
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
