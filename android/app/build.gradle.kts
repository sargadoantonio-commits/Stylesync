plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.stylesync.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.stylesync.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // OAuth Configuration
        // No Facebook configuration required because only Google Sign-In is enabled.
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Force resolution for camera dependencies
    configurations.all {
        resolutionStrategy {
            force("androidx.concurrent:concurrent-futures:1.2.0")
            force("com.google.guava:guava:33.0.0-android")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM ensures all Firebase libraries use compatible versions
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    
    // JSpecify annotations support
    implementation("org.jspecify:jspecify:0.3.0")
    
    // Guava for concurrent futures support
    implementation("com.google.guava:guava:33.0.0-android")
    
    // androidx dependencies - required for camera package compatibility
    implementation("androidx.concurrent:concurrent-futures:1.2.0")
    
    // Essential androidx core libraries
    implementation("androidx.core:core:1.13.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.lifecycle:lifecycle-common:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime:2.7.0")
    
    // CameraX for camera plugin - explicitly pinning versions for compatibility
    implementation("androidx.camera:camera-core:1.3.0")
    implementation("androidx.camera:camera-camera2:1.3.0")
    implementation("androidx.camera:camera-lifecycle:1.3.0")
    implementation("androidx.camera:camera-view:1.3.0")
    
    // OAuth dependencies are handled by Flutter plugins
    // google_sign_in_android and flutter_facebook_auth handle their own dependencies
}
