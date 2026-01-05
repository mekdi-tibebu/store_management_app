# Keep the specific class that was missing in your error log
-keep class com.pichillilorenzo.flutter_inappwebview.InAppWebViewFileProvider { *; }

# Keep all classes in the inappwebview package to prevent other crashes
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }

# General Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Fix for the R8 Compilation error (Missing Play Core classes)
-dontwarn com.google.android.play.core.**

# Keep the InAppWebView classes (from the previous error)
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-keep public class com.pichillilorenzo.flutter_inappwebview.InAppWebViewFileProvider { *; }

# General Flutter ignore rules
-dontwarn io.flutter.embedding.engine.deferredcomponents.**