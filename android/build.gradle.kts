// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    val kotlinVersion by extra("1.8.22")
    
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${kotlinVersion}")
        // Add the Google services Gradle plugin
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// Comment out custom build directory configuration
// rootProject.buildDir = file("../build")

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Comment out custom build directory setting
    // project.buildDir = file("${rootProject.buildDir}/${project.name}")
    
    // This dependency might be causing issues - commenting out
    // if (project.name != "app") {
    //     project.evaluationDependsOn(":app")
    // }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
