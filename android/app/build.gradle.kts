import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

/* -------------------- */
/* Load Keystore Config */
/* -------------------- */

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {

    namespace = "com.stayconnect.diginexa"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    /* -------------------- */
    /* Compile Options      */
    /* -------------------- */

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    /* -------------------- */
    /* Default Config       */
    /* -------------------- */

    defaultConfig {

        applicationId = "com.stayconnect.diginexa"

        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    /* -------------------- */
    /* Signing Config       */
    /* -------------------- */

    signingConfigs {

        create("release") {

            if (keystorePropertiesFile.exists()) {

                keyAlias =
                    keystoreProperties["keyAlias"]?.toString()

                keyPassword =
                    keystoreProperties["keyPassword"]?.toString()

                storeFile = file(
                    keystoreProperties["storeFile"]?.toString() ?: ""
                )

                storePassword =
                    keystoreProperties["storePassword"]?.toString()
            }
        }
    }

    /* -------------------- */
    /* Build Types          */
    /* -------------------- */

    buildTypes {

        getByName("release") {

            signingConfig =
                signingConfigs.getByName("release")

            isMinifyEnabled = true
            isShrinkResources = true
        }

        getByName("debug") {

            signingConfig =
                signingConfigs.getByName("debug")
        }
    }

    /* -------------------- */
    /* Lint Options         */
    /* -------------------- */

    lint {

        checkReleaseBuilds = false
        abortOnError = false
    }
}

/* -------------------- */
/* Flutter Source       */
/* -------------------- */

flutter {
    source = "../.."
}

/* -------------------- */
/* Dependencies         */
/* -------------------- */

dependencies {

    implementation(
        "com.squareup.okhttp3:okhttp:3.12.13"
    )
}