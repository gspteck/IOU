import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.gspteck.iou"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gspteck.iou"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

		signingConfigs {
				create("release") {
						keyAlias = keystoreProperties["keyAlias"] as String
						keyPassword = keystoreProperties["keyPassword"] as String
						storeFile = file(keystoreProperties["storeFile"] as String)
						storePassword = keystoreProperties["storePassword"] as String
				}
		}

   buildTypes {
				getByName("release") {
						signingConfig = signingConfigs.getByName("release")
				}
		} 
}

flutter {
    source = "../.."
}

dependencies {
		// Firebase Dependencies
		implementation("com.google.firebase:firebase-bom:33.9.0")
}
