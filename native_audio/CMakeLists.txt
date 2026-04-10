cmake_minimum_required(VERSION 3.15)
project(JuceAudioEngine VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add JUCE as subdirectory
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/juce")
    add_subdirectory(juce)
else()
    message(WARNING "JUCE not found. Please clone JUCE submodule: git submodule add https://github.com/juce-framework/JUCE.git juce")
endif()

# JUCE Audio Engine Library
juce_add_library(JuceAudioEngine
    SOURCES
        AudioEngine.cpp
        AudioEngine.h
        SamplerVoice.cpp
        SamplerVoice.h
        SamplePlayer.cpp
        SamplePlayer.h
    )

target_link_libraries(JuceAudioEngine PRIVATE
    juce::juce_audio_basics
    juce::juce_audio_devices
    juce::juce_audio_formats
    juce::juce_audio_processors
    juce::juce_core
    )

target_compile_definitions(JuceAudioEngine PUBLIC
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    JUCE_VST3_CAN_COPY_VST2_SDK=0
    )

# Platform channel interface for Flutter
juce_add_console_application(JuceAudioHost
    SOURCES
        Main.cpp
    )

target_link_libraries(JuceAudioHost PRIVATE
    JuceAudioEngine
    juce::juce_audio_basics
    juce::juce_audio_devices
    )
