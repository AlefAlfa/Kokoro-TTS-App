//
//  KModel.swift
//  App
//
//  Created by Lev on 09.03.25.
//

import AVFoundation
import Foundation
import SwiftUI

class TTS: ObservableObject {
    init(model: TTSModel, voice: VoiceConfig, speed: Speed) {
        self.model = model
        self.voice = voice
        self.speed = speed
    }
    
    private let model: TTSModel
    @Published var voice: VoiceConfig
    @Published var speed: Speed
    
    private var task: Task<Void, Never>?
    private var player = AVQueuePlayer()
    
    func start(converting content: ExtractedContent, withPlayback: Bool = false) async {
        task?.cancel()
        task = Task {
            await withTaskCancellationHandler {
                let segments = segment(content.text)
                for segment in segments {
                    if player.items().count >= 2 {
                        if withPlayback {
                            play()
                        }
                    }
                    if segment == "\n" {
                        insertPause()
                        continue
                    }
                    let langauge = content.langauge
                    let audio = await generate(text: segment, voice: voice.speaking(langauge))
                    if Task.isCancelled { return }
                    let fileUrl = audio.save()
                    let item = AVPlayerItem(url: fileUrl)
                    player.insert(item, after: nil)
                }
                print("FINISHED")
                if withPlayback {
                    play()
                }
            } onCancel: {
                reset()
            }
        }
    }
    
    private func generate(text: String, voice: Voice) async -> GeneratedAudio {
        let audio = await model.generate(text: text, sid: voice.id, speed: speed.value)
        return audio
    }
    
    private func segment(_ text: String) -> [String] {
        var sentences = [String]()
        let processedText = text.preProcessed()
        processedText.enumerateSubstrings(in: processedText.startIndex..., options: .bySentences) { sentence, _, _, _ in
            if let sentence {
                sentences.append(sentence)
            }
        }
        return sentences
    }
    
    private func insertPause() {
        if let url = Bundle.main.url(forResource: "silence", withExtension: "wav") {
            let item = AVPlayerItem(url: url)
            player.insert(item, after: nil)
        }
    }
    
    func reset() {
        pause()
        player.removeAllItems()
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}
