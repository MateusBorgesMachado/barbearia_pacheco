import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val releaseStorePath = keystoreProperties.getProperty("storeFile")?.trim().orEmpty()
val releaseStorePassword = keystoreProperties.getProperty("storePassword")?.trim().orEmpty()
val releaseKeyAlias = keystoreProperties.getProperty("keyAlias")?.trim().orEmpty()
val releaseKeyPassword = keystoreProperties.getProperty("keyPassword")?.trim().orEmpty()
val releaseStore = releaseStorePath.takeIf { it.isNotEmpty() }?.let { file(it) }

android {
    namespace = "br.com.brgsystem.barbearia_pacheco"
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
        applicationId = "br.com.brgsystem.barbearia_pacheco"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (releaseStore != null) {
        signingConfigs {
            create("release") {
                storeFile = releaseStore
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (releaseStore != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any { it.name.contains("Release") }
    if (!buildingRelease) {
        return@whenReady
    }

    val problems = mutableListOf<String>()
    if (releaseStore == null || releaseStore.exists().not()) {
        problems += "keystore de upload não encontrado."
    }
    if (releaseStorePassword.isEmpty() || releaseStorePassword == "SENHA_DO_KEYSTORE") {
        problems += "storePassword ainda é o texto de exemplo."
    }
    if (releaseKeyPassword.isEmpty() || releaseKeyPassword == "SENHA_DA_CHAVE") {
        problems += "keyPassword ainda é o texto de exemplo."
    }
    if (releaseKeyAlias.isEmpty()) {
        problems += "keyAlias ausente."
    }
    if (problems.isNotEmpty()) {
        throw GradleException(
            "Build de release recusado para não assinar com a chave de debug. " +
                "Ajuste android/key.properties: ${problems.joinToString(" ")}",
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}