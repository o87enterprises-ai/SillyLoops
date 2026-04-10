package com.samplebeat.samplebeat;

import android.content.Context;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.samplebeat/audio_engine";
    private static final String TAG = "SampleBeat";

    private AudioEngine audioEngine;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        // Initialize audio engine
        audioEngine = new AudioEngine(getApplicationContext());
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "initialize":
                        initializeAudioEngine(result);
                        break;
                    case "playPad":
                        Integer index = call.argument("index");
                        if (index != null) {
                            playPad(index, result);
                        } else {
                            result.error("INVALID_ARGS", "Missing index", null);
                        }
                        break;
                    case "stopPad":
                        index = call.argument("index");
                        if (index != null) {
                            stopPad(index, result);
                        } else {
                            result.error("INVALID_ARGS", "Missing index", null);
                        }
                        break;
                    case "stopAll":
                        stopAll(result);
                        break;
                    case "loadSample":
                        index = call.argument("index");
                        String path = call.argument("path");
                        if (index != null && path != null) {
                            loadSample(index, path, result);
                        } else {
                            result.error("INVALID_ARGS", "Missing arguments", null);
                        }
                        break;
                    case "setBpm":
                        Double bpm = call.argument("bpm");
                        if (bpm != null) {
                            setBpm(bpm, result);
                        } else {
                            result.error("INVALID_ARGS", "Missing bpm", null);
                        }
                        break;
                    case "setLoopMode":
                        index = call.argument("index");
                        Boolean loop = call.argument("loop");
                        if (index != null && loop != null) {
                            setLoopMode(index, loop, result);
                        } else {
                            result.error("INVALID_ARGS", "Missing arguments", null);
                        }
                        break;
                    case "setVolume":
                        index = call.argument("index");
                        Double volume = call.argument("volume");
                        if (index != null && volume != null) {
                            setVolume(index, volume, result);
                        } else {
                            result.error("INVALID_ARGS", "Missing arguments", null);
                        }
                        break;
                    case "clearPad":
                        index = call.argument("index");
                        if (index != null) {
                            clearPad(index, result);
                        } else {
                            result.error("INVALID_ARGS", "Missing index", null);
                        }
                        break;
                    default:
                        result.notImplemented();
                }
            });
    }

    private void initializeAudioEngine(MethodChannel.Result result) {
        Log.d(TAG, "Initializing audio engine...");
        boolean success = audioEngine.initialize();
        if (success) {
            Log.d(TAG, "Audio engine initialized successfully");
            result.success(true);
        } else {
            Log.e(TAG, "Failed to initialize audio engine");
            result.error("INIT_FAILED", "Audio engine initialization failed", null);
        }
    }

    private void playPad(int index, MethodChannel.Result result) {
        Log.d(TAG, "Playing pad " + index);
        audioEngine.playPad(index);
        result.success(true);
    }

    private void stopPad(int index, MethodChannel.Result result) {
        Log.d(TAG, "Stopping pad " + index);
        audioEngine.stopPad(index);
        result.success(true);
    }

    private void stopAll(MethodChannel.Result result) {
        Log.d(TAG, "Stopping all pads");
        audioEngine.stopAll();
        result.success(true);
    }

    private void loadSample(int index, String path, MethodChannel.Result result) {
        Log.d(TAG, "Loading sample " + index + ": " + path);
        boolean success = audioEngine.loadSample(index, path);
        result.success(success);
    }

    private void setBpm(double bpm, MethodChannel.Result result) {
        Log.d(TAG, "Setting BPM: " + bpm);
        audioEngine.setBpm(bpm);
        result.success(true);
    }

    private void setLoopMode(int index, boolean loop, MethodChannel.Result result) {
        Log.d(TAG, "Setting loop mode " + index + ": " + loop);
        audioEngine.setLoopMode(index, loop);
        result.success(true);
    }

    private void setVolume(int index, double volume, MethodChannel.Result result) {
        Log.d(TAG, "Setting volume " + index + ": " + volume);
        audioEngine.setVolume(index, volume);
        result.success(true);
    }

    private void clearPad(int index, MethodChannel.Result result) {
        Log.d(TAG, "Clearing pad " + index);
        audioEngine.clearPad(index);
        result.success(true);
    }

    @Override
    public void onDestroy() {
        if (audioEngine != null) {
            audioEngine.shutdown();
        }
        super.onDestroy();
    }
}
