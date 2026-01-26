import java.util.Properties // 1. Add this at the absolute top

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 2. Add this function right after the plugins block
fun autoIncrementBuildNumber(): Int {
    val versionPropsFile = file("version.properties")
    val versionProps = Properties()
    
    if (versionPropsFile.exists()) {
        versionProps.load(versionPropsFile.inputStream())
    }
    
    val code = (versionProps["VERSION_CODE"]?.toString()?.toInt() ?: 0) + 1
    versionProps["VERSION_CODE"] = code.toString()
    versionProps.store(versionPropsFile.outputStream(), null)
    return code
}

android {
    namespace = "com.example.student_life_manager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.student_life_manager"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        
        // 3. CHANGE THESE TWO LINES:
        versionCode = autoIncrementBuildNumber() 
        versionName = "1.0.$versionCode" // This makes your version name 1.0.1, 1.0.2, etc. automatically
        
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}