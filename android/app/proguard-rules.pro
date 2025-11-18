# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Provider
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * extends androidx.lifecycle.AndroidViewModel { *; }

# Keep Provider classes
-keep class ** extends flutter.**.ChangeNotifier { *; }
-keep class ** implements flutter.**.Listenable { *; }

# Keep all Provider related classes
-keep class com.example.catat_saku.providers.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep data classes for Gson
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Shared Preferences
-keep class androidx.preference.** { *; }
-keep class * extends androidx.preference.PreferenceFragmentCompat

# IntL
-keep class com.ibm.icu.** { *; }
-dontwarn com.ibm.icu.**

# Keep application classes
-keep class com.example.catat_saku.** { *; }
-keep class com.example.catat_saku.models.** { *; }
-keep class com.example.catat_saku.providers.** { *; }
-keep class com.example.catat_saku.pages.** { *; }
