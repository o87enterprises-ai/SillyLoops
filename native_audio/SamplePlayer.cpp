#include "SamplePlayer.h"

SamplePlayer::SamplePlayer() = default;

SamplePlayer::~SamplePlayer()
{
    shutdown();
}

bool SamplePlayer::initialize()
{
    auto result = deviceManager.initialise(
        0,              // input channels
        2,              // output channels
        nullptr,        // XML state
        true,           // select default device
        "",             // preferred device
        nullptr         // preferred setup
    );
    
    if (result.isNotEmpty())
    {
        jassertfalse;
        return false;
    }
    
    engine = std::make_unique<AudioEngine>();
    
    deviceManager.addAudioCallback(engine.get());
    
    return true;
}

void SamplePlayer::shutdown()
{
    if (engine != nullptr)
    {
        deviceManager.removeAudioCallback(engine.get());
        engine.reset();
    }
    
    deviceManager.closeAudioDevice();
}

void SamplePlayer::play(int padIndex)
{
    if (engine)
        engine->playPad(padIndex);
}

void SamplePlayer::stop(int padIndex)
{
    if (engine)
        engine->stopPad(padIndex);
}

void SamplePlayer::stopAll()
{
    if (engine)
        engine->stopAll();
}

bool SamplePlayer::loadSample(int padIndex, const juce::String& filePath)
{
    if (engine)
        return engine->loadSample(padIndex, filePath);
    return false;
}

void SamplePlayer::clearSample(int padIndex)
{
    if (engine)
        engine->clearPad(padIndex);
}

void SamplePlayer::setBpm(double bpm)
{
    if (engine)
        engine->setBpm(bpm);
}

void SamplePlayer::setLoopMode(int padIndex, bool loop)
{
    if (engine)
        engine->setLoopMode(padIndex, loop);
}

void SamplePlayer::setVolume(int padIndex, float volume)
{
    if (engine)
        engine->setVolume(padIndex, volume);
}

void SamplePlayer::enableReverb(bool enabled)
{
    if (engine)
        engine->setReverb(enabled ? 0.5f : 0.0f);
}

void SamplePlayer::enableDelay(bool enabled)
{
    if (engine)
        engine->setDelay(enabled ? 0.3f : 0.0f, enabled ? 0.4f : 0.0f);
}
