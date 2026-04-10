#include "AudioEngine.h"
#include "SamplerVoice.h"

AudioEngine::AudioEngine()
{
    // Initialize 8 sampler voices for 8 pads
    for (int i = 0; i < 8; ++i)
    {
        voices.push_back(std::make_unique<SamplerVoice>());
    }
}

AudioEngine::~AudioEngine() = default;

void AudioEngine::prepareToPlay(double sampleRate, int samplesPerBlock)
{
    currentSampleRate = sampleRate;
    sampleBuffer.setSize(2, samplesPerBlock);
    
    for (auto& voice : voices)
    {
        voice->prepareToPlay(sampleRate, samplesPerBlock);
    }
}

void AudioEngine::releaseResources()
{
    for (auto& voice : voices)
    {
        voice->releaseResources();
    }
}

void AudioEngine::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    const juce::ScopedLock sl(lock);
    
    buffer.clear();
    
    // Process MIDI messages
    for (const auto metadata : midiMessages)
    {
        const auto msg = metadata.getMessage();
        
        if (msg.isNoteOn())
        {
            const int note = msg.getNoteNumber();
            if (note >= 0 && note < 8)
            {
                voices[note]->noteOn(msg.getNoteNumber(), msg.getVelocity());
            }
        }
        else if (msg.isNoteOff())
        {
            const int note = msg.getNoteNumber();
            if (note >= 0 && note < 8)
            {
                voices[note]->noteOff();
            }
        }
    }
    
    // Render all voices
    for (auto& voice : voices)
    {
        voice->renderNextBlock(buffer, 0, buffer.getNumSamples());
    }
}

void AudioEngine::loadSample(int padIndex, const juce::String& filePath)
{
    const juce::ScopedLock sl(lock);
    
    if (padIndex >= 0 && padIndex < 8)
    {
        voices[padIndex]->loadSample(filePath);
    }
}

void AudioEngine::playPad(int padIndex)
{
    const juce::ScopedLock sl(lock);
    
    if (padIndex >= 0 && padIndex < 8)
    {
        voices[padIndex]->noteOn(60, 127);
    }
}

void AudioEngine::stopPad(int padIndex)
{
    const juce::ScopedLock sl(lock);
    
    if (padIndex >= 0 && padIndex < 8)
    {
        voices[padIndex]->noteOff();
    }
}

void AudioEngine::stopAll()
{
    const juce::ScopedLock sl(lock);
    
    for (auto& voice : voices)
    {
        voice->noteOff();
    }
}

void AudioEngine::setBpm(double bpm)
{
    currentBpm = bpm;
    
    // Update tempo-dependent effects
    for (auto& voice : voices)
    {
        voice->setTempo(bpm);
    }
}

void AudioEngine::setLoopMode(int padIndex, bool shouldLoop)
{
    const juce::ScopedLock sl(lock);
    
    if (padIndex >= 0 && padIndex < 8)
    {
        voices[padIndex]->setLoopMode(shouldLoop);
    }
}

void AudioEngine::setVolume(int padIndex, float volume)
{
    const juce::ScopedLock sl(lock);
    
    if (padIndex >= 0 && padIndex < 8)
    {
        voices[padIndex]->setVolume(volume);
    }
}

void AudioEngine::clearPad(int padIndex)
{
    const juce::ScopedLock sl(lock);
    
    if (padIndex >= 0 && padIndex < 8)
    {
        voices[padIndex]->clear();
    }
}

void AudioEngine::setReverb(float amount)
{
    // TODO: Implement reverb effect
}

void AudioEngine::setDelay(float time, float feedback)
{
    // TODO: Implement delay effect
}
