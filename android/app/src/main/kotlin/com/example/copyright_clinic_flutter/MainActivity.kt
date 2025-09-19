package com.example.copyrightClinicFlutter

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.speech.RecognizerIntent
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.speech"
    private var methodResult: MethodChannel.Result? = null
    private lateinit var speechLauncher: ActivityResultLauncher<Intent>
    private lateinit var permissionLauncher: ActivityResultLauncher<String>

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize activity result launchers
        speechLauncher =
                registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result
                    ->
                    handleSpeechResult(result.resultCode, result.data)
                }

        permissionLauncher =
                registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted
                    ->
                    if (isGranted) {
                        startSpeechRecognition()
                    } else {
                        methodResult?.error(
                                "permission_denied",
                                "Microphone permission denied",
                                null
                        )
                        methodResult = null
                    }
                }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                "startSpeech" -> {
                    methodResult = result
                    val prompt = call.argument<String>("prompt")
                    val locale = call.argument<String>("locale")

                    // Check microphone permission
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) ==
                                    PackageManager.PERMISSION_GRANTED
                    ) {
                        startSpeechRecognition(prompt, locale)
                    } else {
                        // Request permission
                        permissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startSpeechRecognition(prompt: String? = null, locale: String? = null) {
        val intent =
                Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                    putExtra(
                            RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                            RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
                    )

                    // Set locale if provided
                    if (locale != null) {
                        putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
                    }

                    // Set prompt if provided
                    if (prompt != null) {
                        putExtra(RecognizerIntent.EXTRA_PROMPT, prompt)
                    }
                }

        try {
            speechLauncher.launch(intent)
        } catch (e: Exception) {
            methodResult?.error(
                    "no_activity",
                    "No speech recognition activity available",
                    e.message
            )
            methodResult = null
        }
    }

    private fun handleSpeechResult(resultCode: Int, data: Intent?) {
        when (resultCode) {
            Activity.RESULT_OK -> {
                val results = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
                val recognizedText = results?.firstOrNull()
                methodResult?.success(recognizedText)
            }
            Activity.RESULT_CANCELED -> {
                methodResult?.success(null)
            }
            else -> {
                methodResult?.success(null)
            }
        }
        methodResult = null
    }
}
