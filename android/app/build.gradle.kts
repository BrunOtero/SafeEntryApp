android {
    compileSdk = 34
    ndkVersion = "25.2.9519653" // Adicione esta linha

    defaultConfig {
        minSdk = 21
        targetSdk = 34
        multiDexEnabled = true // Adicione esta linha
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
}