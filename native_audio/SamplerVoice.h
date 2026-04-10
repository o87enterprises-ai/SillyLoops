#pragma once

#include <JuceHeader.h>

/**
 * Sampler voice class - handles individual sample playback
 * Supports one-shot and loop modes with volume control
 */
class SamplerVoice
{
public:
    SamplerVoice();
    ~SamplerVoice();

    void prepareToPlay(double sampleRate, int samplesPerBlock);
    void releaseResources();
    
    void noteOn(int noteNumber, int velocity);
    void noteOff();
    
    void renderNextBlock(juce::AudioBuffer<float>& outputBuffer,
                        int startSample,
                        int numSamples);

    // Sample management
    bool loadSample(const juce::String& filePath);
    void clear();
    
    // Parameters
    void setLoopMode(bool shouldLoop);
    void setVolume(float volume);
    void setTempo(double bpm);
    
    bool isActive() const { return isVoiceActive; }

private:
    juce::AudioBuffer<float>* sampleData = nullptr;
    double sampleRate = 44100.0;
    
    int noteNumber = 0;
    float velocity = 0.0f;
    float volume = 1.0f;
    
    bool isVoiceActive = false;
    bool loopMode = false;
    
    juce::int64 samplePosition = 0;
    double pitchRatio = 1.0;
    
    double currentBpm = 120.0;
    
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(SamplerVoice)
};
