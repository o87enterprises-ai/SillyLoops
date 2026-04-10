#pragma once

#include <JuceHeader.h>
#include "AudioEngine.h"

/**
 * Sample player wrapper for easier integration
 */
class SamplePlayer
{
public:
    SamplePlayer();
    ~SamplePlayer();

    bool initialize();
    void shutdown();

    // Control interface
    void play(int padIndex);
    void stop(int padIndex);
    void stopAll();
    
    // Sample management
    bool loadSample(int padIndex, const juce::String& filePath);
    void clearSample(int padIndex);
    
    // Parameters
    void setBpm(double bpm);
    void setLoopMode(int padIndex, bool loop);
    void setVolume(int padIndex, float volume);

    // Effects
    void enableReverb(bool enabled);
    void enableDelay(bool enabled);

    AudioEngine* getEngine() { return engine.get(); }

private:
    std::unique_ptr<AudioEngine> engine;
    juce::AudioDeviceManager deviceManager;
    
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(SamplePlayer)
};
