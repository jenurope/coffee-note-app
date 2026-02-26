import org.gradle.api.GradleException
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keyPropertiesFile.exists()
val isReleaseTaskRequested = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("Release", ignoreCase = true) ||
        taskName.contains("bundle", ignoreCase = true)
}
val isProdReleaseTaskRequested = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("ProdRelease", ignoreCase = true) ||
        (
            taskName.contains("prod", ignoreCase = true) &&
                taskName.contains("release", ignoreCase = true)
        )
}

fun parseDartDefines(rawValue: String?): Map<String, String> {
    if (rawValue.isNullOrBlank()) return emptyMap()

    val decoder = Base64.getDecoder()
    return rawValue
        .split(",")
        .mapNotNull { encoded ->
            val trimmed = encoded.trim()
            if (trimmed.isEmpty()) return@mapNotNull null

            val decoded = try {
                String(decoder.decode(trimmed), Charsets.UTF_8)
            } catch (_: IllegalArgumentException) {
                return@mapNotNull null
            }

            val separatorIndex = decoded.indexOf('=')
            if (separatorIndex <= 0) return@mapNotNull null

            decoded.substring(0, separatorIndex) to decoded.substring(separatorIndex + 1)
        }
        .toMap()
}

val dartDefines = parseDartDefines(project.findProperty("dart-defines") as? String)

if (isProdReleaseTaskRequested) {
    val appEnv = dartDefines["APP_ENV"]
    val supabaseUrl = dartDefines["SUPABASE_URL"]
    val supabasePublishableKey = dartDefines["SUPABASE_PUBLISHABLE_KEY"]

    if (appEnv != "prod" || supabaseUrl.isNullOrBlank() || supabasePublishableKey.isNullOrBlank()) {
        throw GradleException(
            "prod release 빌드는 dart define 설정이 필수입니다. " +
                "--dart-define-from-file=dart_define.prod.json 옵션과 " +
                "APP_ENV=prod, SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY 값을 확인하세요.",
        )
    }
}

if (hasReleaseSigning) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

android {
    namespace = "com.gooun.works.coffeelog"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    flavorDimensions += "env"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                val storeFilePath = keyProperties.getProperty("storeFile")
                    ?: throw GradleException("Missing storeFile in android/key.properties")
                val storePasswordValue = keyProperties.getProperty("storePassword")
                    ?: throw GradleException("Missing storePassword in android/key.properties")
                val keyAliasValue = keyProperties.getProperty("keyAlias")
                    ?: throw GradleException("Missing keyAlias in android/key.properties")
                val keyPasswordValue = keyProperties.getProperty("keyPassword")
                    ?: throw GradleException("Missing keyPassword in android/key.properties")

                storeFile = file(storeFilePath)
                storePassword = storePasswordValue
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gooun.works.coffeelog"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "커피로그 DEV")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "커피로그")
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else if (isReleaseTaskRequested) {
                throw GradleException(
                    "android/key.properties not found. Release build requires signing configuration.",
                )
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
