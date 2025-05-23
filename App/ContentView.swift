//
//  ContentView.swift
//  SherpaOnnxTts
//
//  Created by fangjun on 2023/11/23.
//
// Text-to-speech with Next-gen Kaldi on iOS without Internet connection

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var tts = TTS(
        model: SherpaOnnx().createModel(),
        voice: VoiceConfig(english: .heart, chinese: .xiaoxiao),
        speed: .medium
    )
    private let extractor = WebExtractor()

    var body: some View {
        HomeView(tts: tts, extractor: extractor)
    }
}
