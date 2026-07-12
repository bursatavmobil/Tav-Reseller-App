# 1. Aturan Umum Flutter & Core Platform
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 2. Mengabaikan Peringatan Library Pihak Ketiga (Mencegah Gagal Minify)
-dontwarn com.google.android.play.core.**
-dontwarn androidx.**
-dontwarn okhttp3.**
-dontwarn okio.**

# 3. Menjaga Kode Aplikasi Lokal Anda
-keep class com.tav.reseller.** { *; }
-dontwarn com.tav.reseller.**

# 4. Aturan Atribut & Refleksi untuk Anotasi
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,KeepAttributes,AnnotationDefault,Association

# 5. Konfigurasi Khusus WorkManager & Room (Solusi Anti Force Close)
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.** { *; }
-keep class androidx.room.** { *; }

# 6. Dukungan Interaksi JavaScript & File Picker
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# 7. Penyelamat Serialisasi Data Network & JSON (Dio / OkHttp)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# 8. Menjaga SharedPreferences Android agar tidak hilang saat Rilis
-keep class androidx.preference.** { *; }