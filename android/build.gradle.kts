allprojects {
    repositories {
        google()
        mavenCentral()
    }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Ensure all Android subprojects (e.g., Flutter plugins) have a namespace when building with AGP 8+
// This is a safe no-op for modules that already define a namespace
subprojects {
    plugins.withId("com.android.library") {
        // Use FQCN to avoid import issues inside the build script
        extensions.configure(com.android.build.api.dsl.LibraryExtension::class.java) {
            // Only set when missing to avoid overriding plugin defaults
            if (namespace == null || namespace!!.isEmpty()) {
                namespace = "com.ourbit." + project.name.replace("-", "_")
            }
        }
    }
    plugins.withId("com.android.application") {
        extensions.configure(com.android.build.api.dsl.ApplicationExtension::class.java) {
            if (namespace == null || namespace!!.isEmpty()) {
                namespace = "com.ourbit." + project.name.replace("-", "_")
            }
        }
    }
}
