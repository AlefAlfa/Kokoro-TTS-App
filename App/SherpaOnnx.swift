/// swfit-api-examples/SherpaOnnx.swift
/// Copyright (c)  2023  Xiaomi Corporation

import Foundation  // For NSString

fileprivate func toCPointer(_ s: String) -> UnsafePointer<Int8>! {
    let cs = (s as NSString).utf8String
    return UnsafePointer<Int8>(cs)
}

protocol TTSModel {
    func generate(text: String, sid: Int, speed: Float) async -> GeneratedAudio
}

protocol GeneratedAudio {
    func save() -> URL
}

class SherpaOnnx {
    // used to get the path to espeak-ng-data
    func resourceURL(to path: String) -> String {
      return URL(string: path, relativeTo: Bundle.main.resourceURL)!.path
    }

    func getResource(_ forResource: String, _ ofType: String) -> String {
      let path = Bundle.main.path(forResource: forResource, ofType: ofType)
      precondition(
        path != nil,
        "\(forResource).\(ofType) does not exist!\n" + "Remember to change \n"
          + "  Build Phases -> Copy Bundle Resources\n" + "to add it!"
      )
      return path!
    }

    private func getTtsFor_kokoro_multi_lang_v1_0() -> SherpaOnnx.KModelWrapper {
      // please see https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/kokoro.html

      let model = getResource("model", "onnx")
      let voices = getResource("voices", "bin")

      // tokens.txt
      let tokens = getResource("tokens", "txt")

      let lexicon_en = getResource("lexicon-us-en", "txt")
      let lexicon_zh = getResource("lexicon-zh", "txt")
      let lexicon = "\(lexicon_en),\(lexicon_zh)"

      // in this case, we don't need lexicon.txt
      let dataDir = resourceURL(to: "espeak-ng-data")
      let dictDir = resourceURL(to: "dict")

      let kokoro = sherpaOnnxOfflineTtsKokoroModelConfig(
        model: model, voices: voices, tokens: tokens, dataDir: dataDir,
        dictDir: dictDir, lexicon: lexicon)
      let modelConfig = sherpaOnnxOfflineTtsModelConfig(kokoro: kokoro)
      var config = sherpaOnnxOfflineTtsConfig(model: modelConfig)

      return KModelWrapper(config: &config)
    }

    func createModel() -> SherpaOnnx.KModelWrapper {
      return getTtsFor_kokoro_multi_lang_v1_0()
    }
    
    private func sherpaOnnxOfflineTtsKokoroModelConfig(
        model: String = "",
        voices: String = "",
        tokens: String = "",
        dataDir: String = "",
        lengthScale: Float = 1.0,
        dictDir: String = "",
        lexicon: String = ""
    ) -> SherpaOnnxOfflineTtsKokoroModelConfig {
        return SherpaOnnxOfflineTtsKokoroModelConfig(
            model: toCPointer(model),
            voices: toCPointer(voices),
            tokens: toCPointer(tokens),
            data_dir: toCPointer(dataDir),
            length_scale: lengthScale,
            dict_dir: toCPointer(dictDir),
            lexicon: toCPointer(lexicon)
        )
    }
    
    private func sherpaOnnxOfflineTtsModelConfig(
        vits: SherpaOnnxOfflineTtsVitsModelConfig = SherpaOnnxOfflineTtsVitsModelConfig(),
        matcha: SherpaOnnxOfflineTtsMatchaModelConfig = SherpaOnnxOfflineTtsMatchaModelConfig(),
        kokoro: SherpaOnnxOfflineTtsKokoroModelConfig = SherpaOnnxOfflineTtsKokoroModelConfig(),
        numThreads: Int = 1,
        debug: Int = 0,
        provider: String = "cpu"
    ) -> SherpaOnnxOfflineTtsModelConfig {
        return SherpaOnnxOfflineTtsModelConfig(
            vits: vits,
            num_threads: Int32(numThreads),
            debug: Int32(debug),
            provider: toCPointer(provider),
            matcha: matcha,
            kokoro: kokoro
        )
    }
    
    private func sherpaOnnxOfflineTtsConfig(
        model: SherpaOnnxOfflineTtsModelConfig,
        ruleFsts: String = "",
        ruleFars: String = "",
        maxNumSentences: Int = 1,
        silenceScale: Float = 0.2
    ) -> SherpaOnnxOfflineTtsConfig {
        return SherpaOnnxOfflineTtsConfig(
            model: model,
            rule_fsts: toCPointer(ruleFsts),
            max_num_sentences: Int32(maxNumSentences),
            rule_fars: toCPointer(ruleFars),
            silence_scale: silenceScale
        )
    }
    
    class KModelWrapper: TTSModel {
        
        typealias TtsCallbackWithArg = (
            @convention(c) (
                UnsafePointer<Float>?,  // const float* samples
                Int32,  // int32_t n
                UnsafeMutableRawPointer?  // void *arg
            ) -> Int32
        )?
        /// A pointer to the underlying counterpart in C
        let tts: OpaquePointer!
        
        /// Constructor taking a model config
        init(
            config: UnsafePointer<SherpaOnnxOfflineTtsConfig>!
        ) {
            tts = SherpaOnnxCreateOfflineTts(config)
        }
        
        deinit {
            if let tts {
                SherpaOnnxDestroyOfflineTts(tts)
            }
        }
        
        func generate(text: String, sid: Int = 0, speed: Float = 1.0) async -> GeneratedAudio {
            let audio: UnsafePointer<SherpaOnnxGeneratedAudio>? = SherpaOnnxOfflineTtsGenerate(
                tts,
                toCPointer(text),
                Int32(sid),
                speed
            )
            
            return GeneratedAudioWrapper(audio: audio)
        }
        
        func generateWithCallbackWithArg(
            text: String, callback: TtsCallbackWithArg, arg: UnsafeMutableRawPointer, sid: Int = 0,
            speed: Float = 1.0
        ) -> GeneratedAudioWrapper {
            let audio: UnsafePointer<SherpaOnnxGeneratedAudio>? =
            SherpaOnnxOfflineTtsGenerateWithCallbackWithArg(
                tts, toCPointer(text), Int32(sid), speed, callback, arg)
            
            return GeneratedAudioWrapper(audio: audio)
        }
    }
    
    class GeneratedAudioWrapper: GeneratedAudio {
        /// A pointer to the underlying counterpart in C
        let audio: UnsafePointer<SherpaOnnxGeneratedAudio>!
        
        init(audio: UnsafePointer<SherpaOnnxGeneratedAudio>!) {
            self.audio = audio
        }
        
        deinit {
            if let audio {
                SherpaOnnxDestroyOfflineTtsGeneratedAudio(audio)
            }
        }
        
        var n: Int32 {
            return audio.pointee.n
        }
        
        var sampleRate: Int32 {
            return audio.pointee.sample_rate
        }
        
        var samples: [Float] {
            if let p = audio.pointee.samples {
                var samples: [Float] = []
                for index in 0..<n {
                    samples.append(p[Int(index)])
                }
                return samples
            } else {
                let samples: [Float] = []
                return samples
            }
        }
        
        func save() -> URL {
            let tempDirectoryURL = NSURL.fileURL(withPath: "tmp", isDirectory: true)
            let filename = tempDirectoryURL.appendingPathComponent("\(UUID().uuidString).wav")
            let filenameString = filename.path
            print("audio file: \(filenameString)")
            let _ = SherpaOnnxWriteWave(audio.pointee.samples, n, sampleRate, toCPointer(filenameString))
            return filename
        }
    }
}
