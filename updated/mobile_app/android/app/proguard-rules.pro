# Prevent R8 from stripping the WebView FileProvider
-keep class com.pichillilorenzo.flutter_inappwebview.InAppWebViewFileProvider { *; }
-keep public class * extends com.pichillilorenzo.flutter_inappwebview.InAppWebViewFileProvider

# Keep the entire package just to be safe
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }

# Basic Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Fix for the R8 Compilation error (Missing Play Core classes)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Also add this to ensure Flutter's internal components aren't stripped
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }