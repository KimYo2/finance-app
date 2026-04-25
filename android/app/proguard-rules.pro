# Keep ML Kit Text Recognition
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep missing script classes (Chinese, Japanese, Korean, Devanagari)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep Tesseract
-keep class io.paratoner.flutter_tesseract_ocr.** { *; }
-dontwarn io.paratoner.flutter_tesseract_ocr.**