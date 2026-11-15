# ProGuard & R8 keep rules for GhorBD Flutter App

# Flutter Secure Storage
-keep class androidx.security.crypto.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Local Auth (Biometric authentication)
-keep class io.flutter.plugins.localauth.** { *; }
-keep class androidx.biometric.** { *; }

# Flutter Jailbreak Detection & RootBeer
-keep class appmire.be.flutterjailbreakdetection.** { *; }
-keep class com.scottyab.rootbeer.** { *; }
-keepclassmembers class com.scottyab.rootbeer.** { *; }

# Flutter Wrapper and plugins reflection
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Suppress warnings for Flutter engine optional Play Core deferred components
-dontwarn com.google.android.play.core.**
