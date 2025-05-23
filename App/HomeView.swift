//
//  MainView.swift
//  App
//
//  Created by Lev on 22.03.25.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    init(tts: TTS, extractor: ContentExtractor) {
        self.tts = tts
        self.extractor = extractor
    }
    
    @ObservedObject var tts: TTS
    @Published var areSettingsPresented = false
    @Published var textEditorContent = ""
    @Published var urlFieldContent = ""
    let extractor: ContentExtractor
}

struct HomeView: View {
    init(tts: TTS , extractor: ContentExtractor) {
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                tts: tts,
                extractor: extractor
            )
        )
    }
    
    @StateObject private var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button("", systemImage: "gearshape") {
                    $viewModel.areSettingsPresented.wrappedValue.toggle()
                }
                .foregroundStyle(.foreground)
            }
            Spacer()
            
            TextEditor(text: $viewModel.textEditorContent)
                .autocorrectionDisabled()
            
            TextField("", text: $viewModel.urlFieldContent)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

            HStack {
                Spacer()
                Button("play") {
                    Task {
                        if !viewModel.textEditorContent.isEmpty {
                            let language = try? viewModel.textEditorContent.language()
                            let content = ExtractedContent(text: viewModel.textEditorContent, langauge: language ?? .english)
                            await viewModel.tts.start(converting: content, withPlayback: true)
                        } else {
                            let url = URL(string: viewModel.urlFieldContent)!
                            let content = try await viewModel.extractor.extractContent(from: url)
                            await viewModel.tts.start(converting: content, withPlayback: true)
                        }
                    }
                }
                Spacer()
                Button("pause") {
                    viewModel.tts.pause()
                }
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.areSettingsPresented) {
            SettingsView(tts: viewModel.tts)
        }
    }
}
