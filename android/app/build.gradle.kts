import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
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
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
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
		implementation("com.appodeal.ads:sdk:3.4.2.0") {
        // Ad networks
        exclude(group = "com.appodeal.ads.sdk.networks", module = "admob")
        exclude(group = "org.bidon", module = "admob-adapter")
        exclude(group = "org.bidon", module = "gam-adapter")
        exclude(group = "com.applovin.mediation", module = "google-adapter")
        exclude(group = "com.applovin.mediation", module = "google-ad-manager-adapter")
        // Services
        exclude(group = "com.appodeal.ads.sdk.services", module = "adjust")
        exclude(group = "com.appodeal.ads.sdk.services", module = "appsflyer")
        exclude(group = "com.appodeal.ads.sdk.services", module = "firebase")
        exclude(group = "com.appodeal.ads.sdk.services", module = "facebook_analytics")
    }	
}
