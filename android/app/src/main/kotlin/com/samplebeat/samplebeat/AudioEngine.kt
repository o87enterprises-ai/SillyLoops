package com.samplebeat.samplebeat;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.HashMap;
import java.util.Map;

/**
 * Android audio engine using AudioTrack for sample playback
 * This is a simplified implementation - JUCE would provide lower latency
 */
public class AudioEngine {
    private static final String TAG = "AudioEngine";
    private static final int SAMPLE_RATE = 44100;
    
    private final Context context;
    private final Map<Integer, SampleData> loadedSamples;
    private final Map<Integer, AudioTrack> activeTracks;
    
    private double bpm = 120.0;
    private boolean initialized = false;
    
    private static class SampleData {
        final String path;
        final byte[] audioData;
        final int sampleRate;
        final int channels;
        boolean loopMode;
        float volume;
        
        SampleData(String path, byte[] audioData, int sampleRate, int channels) {
            this.path = path;
            this.audioData = audioData;
            this.sampleRate = sampleRate;
            this.channels = channels;
            this.loopMode = false;
            this.volume = 1.0f;
        }
    }
    
    public AudioEngine(Context context) {
        this.context = context;
        this.loadedSamples = new HashMap<>();
        this.activeTracks = new HashMap<>();
    }
    
    public boolean initialize() {
        if (initialized) {
            return true;
        }
        
        try {
            // Verify audio capabilities
            AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
            if (audioManager != null) {
                String sampleRateStr = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE);
                String framesPerBufferStr = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER);
                Log.d(TAG, "Output sample rate: " + sampleRateStr);
                Log.d(TAG, "Frames per buffer: " + framesPerBufferStr);
            }
            
            initialized = true;
            Log.d(TAG, "Audio engine initialized");
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Failed to initialize audio engine", e);
            return false;
        }
    }
    
    public void shutdown() {
        stopAll();
        loadedSamples.clear();
        initialized = false;
    }
    
    public boolean loadSample(int index, String path) {
        try {
            File file = new File(path);
            if (!file.exists()) {
                Log.e(TAG, "Sample file not found: " + path);
                return false;
            }
            
            // For WAV files, we need to parse the header
            byte[] audioData = readWavFile(file);
            if (audioData != null) {
                loadedSamples.put(index, new SampleData(path, audioData, SAMPLE_RATE, 2));
                Log.d(TAG, "Loaded sample " + index + ": " + path);
                return true;
            }
            
            return false;
        } catch (IOException e) {
            Log.e(TAG, "Failed to load sample", e);
            return false;
        }
    }
    
    private byte[] readWavFile(File file) throws IOException {
        FileInputStream fis = new FileInputStream(file);
        byte[] fileData = new byte[(int) file.length()];
        fis.read(fileData);
        fis.close();
        
        // Skip WAV header (44 bytes typically)
        int headerSize = 44;
        if (fileData.length > headerSize) {
            byte[] audioData = new byte[fileData.length - headerSize];
            System.arraycopy(fileData, headerSize, audioData, 0, audioData.length);
            return audioData;
        }
        
        return null;
    }
    
    public void playPad(int index) {
        SampleData sample = loadedSamples.get(index);
        if (sample == null) {
            Log.w(TAG, "No sample loaded for pad " + index);
            return;
        }
        
        // Stop existing playback on this pad
        stopPad(index);
        
        try {
            int bufferSize = AudioTrack.getMinBufferSize(
                SAMPLE_RATE,
                sample.channels == 2 ? AudioFormat.CHANNEL_OUT_STEREO : AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            );
            
            AudioAttributes attributes = new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build();
            
            AudioFormat format = new AudioFormat.Builder()
                .setSampleRate(SAMPLE_RATE)
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setChannelMask(sample.channels == 2 ? AudioFormat.CHANNEL_OUT_STEREO : AudioFormat.CHANNEL_OUT_MONO)
                .build();
            
            AudioTrack audioTrack = new AudioTrack(
                attributes,
                format,
                bufferSize,
                AudioTrack.MODE_STREAM,
                AudioManager.AUDIO_SESSION_ID_GENERATE
            );
            
            audioTrack.setVolume(sample.volume);
            audioTrack.setLoopMode(sample.loopMode ? AudioTrack.LOOP_INFINITE : AudioTrack.LOOP_NONE);
            if (sample.loopMode) {
                audioTrack.setLoopPoints(0, sample.audioData.length / 2, -1);
            }
            
            audioTrack.play();
            audioTrack.write(sample.audioData, 0, sample.audioData.length);
            
            activeTracks.put(index, audioTrack);
            Log.d(TAG, "Playing pad " + index);
            
        } catch (Exception e) {
            Log.e(TAG, "Failed to play sample", e);
        }
    }
    
    public void stopPad(int index) {
        AudioTrack track = activeTracks.remove(index);
        if (track != null) {
            try {
                track.stop();
                track.release();
                Log.d(TAG, "Stopped pad " + index);
            } catch (Exception e) {
                Log.e(TAG, "Failed to stop pad", e);
            }
        }
    }
    
    public void stopAll() {
        for (int index : activeTracks.keySet()) {
            stopPad(index);
        }
        activeTracks.clear();
    }
    
    public void setBpm(double bpm) {
        this.bpm = bpm;
        Log.d(TAG, "BPM set to: " + bpm);
    }
    
    public void setLoopMode(int index, boolean loop) {
        SampleData sample = loadedSamples.get(index);
        if (sample != null) {
            sample.loopMode = loop;
            Log.d(TAG, "Loop mode for pad " + index + ": " + loop);
        }
    }
    
    public void setVolume(int index, double volume) {
        SampleData sample = loadedSamples.get(index);
        if (sample != null) {
            sample.volume = (float) Math.max(0.0, Math.min(1.0, volume));
            Log.d(TAG, "Volume for pad " + index + ": " + sample.volume);
        }
    }
    
    public void clearPad(int index) {
        stopPad(index);
        loadedSamples.remove(index);
        Log.d(TAG, "Cleared pad " + index);
    }
}
