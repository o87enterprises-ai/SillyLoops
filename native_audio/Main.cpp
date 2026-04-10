#include <JuceHeader.h>
#include "SamplePlayer.h"

/**
 * Main entry point for JUCE audio host
 * This is used for testing the audio engine standalone
 */
class AudioHostApplication : public juce::JUCEApplication
{
public:
    AudioHostApplication() : application(nullptr) {}

    void initialise(const juce::String&) override
    {
        DBG("SampleBeat Audio Engine Starting...");
        
        application = std::make_unique<SamplePlayer>();
        
        if (!application->initialize())
        {
            DBG("Failed to initialize audio engine!");
            quit();
            return;
        }
        
        DBG("Audio engine initialized successfully!");
        DBG("Loading test samples...");
        
        // Load some test samples (paths would be configured for your system)
        // application->loadSample(0, "/path/to/kick.wav");
        // application->loadSample(1, "/path/to/snare.wav");
        
        DBG("Audio host ready. Press any key to exit...");
    }

    void shutdown() override
    {
        if (application)
        {
            application->stopAll();
            application->shutdown();
            application.reset();
        }
        
        DBG("Audio engine shutdown complete.");
    }

private:
    std::unique_ptr<SamplePlayer> application;
};

START_JUCE_APPLICATION(AudioHostApplication)
