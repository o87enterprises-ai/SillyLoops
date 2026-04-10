#include "SamplerVoice.h"

SamplerVoice::SamplerVoice() = default;

SamplerVoice::~SamplerVoice()
{
    clear();
}

void SamplerVoice::prepareToPlay(double sampleRate, int)
{
    this->sampleRate = sampleRate;
}

void SamplerVoice::releaseResources()
{
    isVoiceActive = false;
}

void SamplerVoice::noteOn(int noteNumber, int velocity)
{
    if (sampleData == nullptr || sampleData->getNumSamples() == 0)
        return;
    
    this->noteNumber = noteNumber;
    this->velocity = static_cast<float>(velocity) / 127.0f;
    this->isVoiceActive = true;
    this->samplePosition = 0;
    
    // Calculate pitch ratio based on MIDI note (middle C = 60)
    pitchRatio = std::pow(2.0, (noteNumber - 60) / 12.0);
}

void SamplerVoice::noteOff()
{
    if (!loopMode)
    {
        isVoiceActive = false;
    }
}

void SamplerVoice::renderNextBlock(juce::AudioBuffer<float>& outputBuffer,
                                   int startSample,
                                   int numSamples)
{
    if (!isVoiceActive || sampleData == nullptr)
        return;
    
    const int numChannels = juce::jmin(outputBuffer.getNumChannels(),
                                        sampleData->getNumChannels());
    const int sampleLength = sampleData->getNumSamples();
    
    for (int sample = 0; sample < numSamples; ++sample)
    {
        if (samplePosition >= sampleLength)
        {
            if (loopMode)
            {
                samplePosition = 0;
            }
            else
            {
                isVoiceActive = false;
                break;
            }
        }
        
        for (int channel = 0; channel < numChannels; ++channel)
        {
            auto* destData = outputBuffer.getWritePointer(channel);
            const auto* srcData = sampleData->getReadPointer(channel);
            
            destData[startSample + sample] += 
                srcData[samplePosition] * velocity * volume;
        }
        
        samplePosition += static_cast<juce::int64>(pitchRatio);
    }
}

bool SamplerVoice::loadSample(const juce::String& filePath)
{
    juce::File file(filePath);
    
    if (!file.existsAsFile())
    {
        jassertfalse;
        return false;
    }
    
    juce::AudioFormatManager formatManager;
    formatManager.registerBasicFormats();
    
    std::unique_ptr<juce::AudioFormatReader> reader(
        formatManager.createReaderFor(file));
    
    if (reader == nullptr)
        return false;
    
    auto newBuffer = std::make_unique<juce::AudioBuffer<float>>(
        reader->numChannels,
        static_cast<int>(reader->lengthInSamples));
    
    reader->read(newBuffer.get(), 0, reader->lengthInSamples, 0, true, true);
    
    sampleData = newBuffer.release();
    sampleRate = reader->sampleRate;
    
    return true;
}

void SamplerVoice::clear()
{
    delete sampleData;
    sampleData = nullptr;
    isVoiceActive = false;
    samplePosition = 0;
}

void SamplerVoice::setLoopMode(bool shouldLoop)
{
    loopMode = shouldLoop;
}

void SamplerVoice::setVolume(float vol)
{
    volume = juce::jlimit(0.0f, 1.0f, vol);
}

void SamplerVoice::setTempo(double bpm)
{
    currentBpm = bpm;
    // Could adjust playback speed based on tempo for time-stretching
}
