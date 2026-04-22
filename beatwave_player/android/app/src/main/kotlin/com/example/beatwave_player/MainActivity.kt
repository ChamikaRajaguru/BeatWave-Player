package com.example.beatwave_player

import android.media.audiofx.BassBoost
import android.media.audiofx.Equalizer
import android.media.audiofx.Virtualizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.beatwave.equalizer"
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null
    private var virtualizer: Virtualizer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    try {
                        val audioSessionId = call.argument<Int>("audioSessionId") ?: 0
                        
                        // Release previous instances
                        releaseEffects()
                        
                        // Initialize equalizer
                        equalizer = Equalizer(0, audioSessionId).apply {
                            enabled = true
                        }
                        
                        // Initialize bass boost
                        bassBoost = BassBoost(0, audioSessionId).apply {
                            enabled = true
                        }
                        
                        // Initialize virtualizer
                        virtualizer = Virtualizer(0, audioSessionId).apply {
                            enabled = true
                        }
                        
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", e.message, null)
                    }
                }
                
                "setEnabled" -> {
                    try {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        equalizer?.enabled = enabled
                        bassBoost?.enabled = enabled
                        virtualizer?.enabled = enabled
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ENABLE_ERROR", e.message, null)
                    }
                }
                
                "setBandLevel" -> {
                    try {
                        val band = call.argument<Int>("band") ?: 0
                        val level = call.argument<Int>("level") ?: 0
                        equalizer?.setBandLevel(band.toShort(), level.toShort())
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("BAND_ERROR", e.message, null)
                    }
                }
                
                "setBassBoost" -> {
                    try {
                        val strength = call.argument<Int>("strength") ?: 0
                        bassBoost?.setStrength(strength.toShort())
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("BASS_ERROR", e.message, null)
                    }
                }
                
                "setVirtualizer" -> {
                    try {
                        val strength = call.argument<Int>("strength") ?: 0
                        virtualizer?.setStrength(strength.toShort())
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("VIRTUAL_ERROR", e.message, null)
                    }
                }
                
                "release" -> {
                    releaseEffects()
                    result.success(true)
                }
                
                else -> result.notImplemented()
            }
        }
    }
    
    private fun releaseEffects() {
        try {
            equalizer?.release()
            equalizer = null
            bassBoost?.release()
            bassBoost = null
            virtualizer?.release()
            virtualizer = null
        } catch (e: Exception) {
            // Ignore release errors
        }
    }
    
    override fun onDestroy() {
        releaseEffects()
        super.onDestroy()
    }
}
