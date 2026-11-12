allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// W0-4 (#277): algunos plugins de pub no declaran `namespace` y AGP 8 lo exige,
// así que en un checkout limpio el AAB no compila (p.ej. record 4.4.4, que es
// el plugin de voz). Antes se arreglaba a mano en la caché de pub del equipo: eso
// no viaja al CI. Aquí se inyecta el namespace que falta, tomándolo del `group`
// del propio plugin, y solo si la extensión android no trae uno.
// Se usa reflexión para no meter AGP en el classpath de este build script.
// Debe declararse ANTES del evaluationDependsOn de abajo: si el proyecto ya está
// evaluado, afterEvaluate lanza "project is already evaluated".
subprojects {
    afterEvaluate {
        val androidExt = project.extensions.findByName("android") ?: return@afterEvaluate
        val getter = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" } ?: return@afterEvaluate
        if (getter.invoke(androidExt) != null) return@afterEvaluate

        val namespace = (project.group as? String)?.takeIf { it.isNotBlank() }
            ?: "dev.flutter.${project.name}"
        androidExt.javaClass.methods
            .firstOrNull { it.name == "setNamespace" && it.parameterTypes.size == 1 }
            ?.invoke(androidExt, namespace)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
