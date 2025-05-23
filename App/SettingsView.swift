//
//  SettingsView.swift
//  App
//
//  Created by Lev on 22.03.25.
//

import SwiftUI

struct SettingsView: View {
    @State private var isPresented = false
    @ObservedObject private var tts: TTS
    
    init(tts: TTS) {
        self.tts = tts
    }
    
    var body: some View {
        NavigationStack {
            List {
                voicePickerTrigger
                    .sheet(isPresented: $isPresented) {
                        HStack {
                            Picker("English", selection: $tts.voice.english) {
                                ForEach(Voice.allCases.filter { $0.language == .english }) { voice in
                                    Text(voice.rawValue.capitalized).tag(voice)
                                }
                            }
                            Picker("Chinese", selection: $tts.voice.chinese) {
                                ForEach(Voice.allCases.filter { $0.language == .chinese }) { voice in
                                    Text(voice.rawValue.capitalized).tag(voice)
                                }
                            }
                        }
                        .presentationDetents([.height(100)])
                    }
                speedPicker
            }
        }
    }
    
    private var voicePickerTrigger: some View {
        Button {
            isPresented.toggle()
        } label: {
            NavigationLink("Voice", destination: EmptyView())
        }
        .foregroundColor(Color(uiColor: .label))
        .onChange(of: tts.voice.english) {
            let content = ExtractedContent(text: "I think that most people are underestimating just how radical the upside of AI could be", langauge: .english)
            Task {
                await tts.start(converting: content, withPlayback: true)
            }
        }
        .onChange(of: tts.voice.chinese) {
            let content = ExtractedContent(text: "我认为大多数人都低估了人工智能可能带来的颠覆性好处", langauge: .chinese)
            Task {
                await tts.start(converting: content, withPlayback: true)
            }
        }
    }
    
    private var speedPicker: some View {
        Picker("Speed", selection: $tts.speed) {
            ForEach(Speed.allCases) { speed in
                Text(speed.rawValue.capitalized)
            }
        }
    }
}
