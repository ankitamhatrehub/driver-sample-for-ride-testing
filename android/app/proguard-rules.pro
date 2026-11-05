# ML Kit text recognition: the plugin references the optional Chinese,
# Devanagari, Japanese and Korean recognizers, which the app does not bundle
# (it only uses the Latin script). Ignore them so R8 does not fail.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
