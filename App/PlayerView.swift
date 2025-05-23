//
//  PlayerView.swift
//  App
//
//  Created by Lev on 23.03.25.
//

import SwiftUI

struct PlayerView: View {
    @State private var isPlaying: Bool = false
    @State private var currentTime: Double = 75
    let totalTime: Double = 7 * 60 + 33
    @StateObject private var viewModel = PlayerViewModel()

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image("album_artwork")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .cornerRadius(12)

                    VStack(spacing: 2) {
                        Text("Magic Portal (Electric Universe)")
                            .foregroundColor(.white)
                            .font(.headline)

                        Text("Alpha Portal, Magik")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.subheadline)
                    }
                }

                HStack {
                    controlButton(systemName: "hand.thumbsup.fill", count: "9.5K")
                    controlButton(systemName: "text.bubble.fill", count: "47")
                    controlButton(systemName: "star", count: "Save")
                    controlButton(systemName: "square.and.arrow.up", count: "Share")
                }

                VStack {
                    Slider(value: $currentTime, in: 0...totalTime)
                        .accentColor(.white)

                    HStack {
                        Text(formatTime(currentTime))
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)

                        Spacer()

                        Text(formatTime(totalTime))
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 40) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }

                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }

                HStack {
                    Spacer()
                    footerButton("UP NEXT")
                    Spacer()
                    footerButton("LYRICS")
                    Spacer()
                    footerButton("RELATED")
                    Spacer()
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainder = totalSeconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }

    private func controlButton(systemName: String, count: String) -> some View {
        VStack(spacing: 4) {
            Button(action: {}) {
                Image(systemName: systemName)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            if !count.isEmpty {
                Text(count)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(minWidth: 50)
    }

    private func footerButton(_ title: String) -> some View {
        Button(action: {}) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

class PlayerViewModel: ObservableObject {
    func getDuration(of content: ExtractedContent, speed: Speed) -> Double {
        let wordCount = content.title.wordCount() + content.text.wordCount()
        let paragraphCount = content.text.paragraphCount()
        let wordDuraton = content.langauge.duration * Double(wordCount)
        let paragraphDuration = Constants.Duration.paragraph
        let totalDuration = (wordDuraton + paragraphDuration) / Double(speed.value)

        return totalDuration
    }
    
    
}

struct Constants {
    struct Duration {
        static let paragraph = 0.5
        static let english = 0.305
        static let chinese = 0.305 // TODO: check real time
    }
}
