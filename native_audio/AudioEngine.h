#pragma once

#include <JuceHeader.h>
#include <vector>
#include <memory>

class SamplerVoice;

/**
 * Main audio engine class that handles audio processing
 * Interfaces with Flutter via platform channels
 */
class AudioEngine : public juce::AudioProcessor
{
public:
    AudioEngine();
    ~AudioEngine() override;

    // AudioProcessor interface
    void prepareToPlay(double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;
    void processBlock(juce::AudioBuffer<float>&, juce::MidiBuffer&) override;

    // Implementation details
    const juce::String getName() const override { return "JuceAudioEngine"; }
    bool acceptsMidi() const override { return true; }
    bool producesMidi() const override { return false; }
    bool isMidiEffect() const override { return false; }
    double getTailLengthSeconds() const override { return 0.0; }

    const juce::AudioProcessorEditor* createEditor() override { return nullptr; }
    bool hasEditor() const override { return false; }

    int getNumPrograms() override { return 1; }
    int getCurrentProgram() override { return 0; }
    void setCurrentProgram(int) override {}
    const juce::String getProgramName(int) override { return ""; }
    void changeProgramName(int, const juce::String&) override {}

    void getStateInformation(juce::MemoryBlock&) override {}
    void setStateInformation(const void*, int) override {}

    // Public API for Flutter interface
    void loadSample(int padIndex, const juce::String& filePath);
    void playPad(int padIndex);
    void stopPad(int padIndex);
    void stopAll();
    void setBpm(double bpm);
    void setLoopMode(int padIndex, bool shouldLoop);
    void setVolume(int padIndex, float volume);
    void clearPad(int padIndex);

    // Effects
    void setReverb(float amount);
    void setDelay(float time, float feedback);

private:
    std::vector<std::unique_ptr<SamplerVoice>> voices;
    juce::AudioBuffer<float> sampleBuffer;
    double currentSampleRate = 44100.0;
    double currentBpm = 120.0;
    
    juce::CriticalSection lock;
    
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(AudioEngine)
};
