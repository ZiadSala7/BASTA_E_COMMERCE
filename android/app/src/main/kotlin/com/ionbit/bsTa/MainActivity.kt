package com.ionbit.bsTa

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "busta/debug_signing",
        ).setMethodCallHandler { call, result ->
            if (call.method != "getSigningInfo") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            try {
                val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    packageManager.getPackageInfo(
                        packageName,
                        PackageManager.GET_SIGNING_CERTIFICATES,
                    )
                } else {
                    @Suppress("DEPRECATION")
                    packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                }

                val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    packageInfo.signingInfo?.apkContentsSigners
                } else {
                    @Suppress("DEPRECATION")
                    packageInfo.signatures
                }

                if (signatures.isNullOrEmpty()) {
                    result.error(
                        "SIGNING_INFO_MISSING",
                        "No app signing certificate was found.",
                        null,
                    )
                    return@setMethodCallHandler
                }

                result.success(
                    mapOf(
                        "packageName" to packageName,
                        "sha1" to signatures.map { it.digest("SHA-1") },
                        "sha256" to signatures.map { it.digest("SHA-256") },
                    ),
                )
            } catch (error: Exception) {
                result.error("SIGNING_INFO_ERROR", error.message, null)
            }
        }
    }

    private fun android.content.pm.Signature.digest(algorithm: String): String {
        val bytes = MessageDigest.getInstance(algorithm).digest(toByteArray())
        return bytes.joinToString(":") { byte ->
            "%02X".format(byte.toInt() and 0xFF)
        }
    }
}
