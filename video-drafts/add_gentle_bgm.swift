import AVFoundation
import Foundation

let inputURL = URL(fileURLWithPath: "/Users/gouke/Desktop/涌波_動画スライド_v20_20260617-192643/施設の過ごし方動画（涌波）.mp4")
let outputURL = URL(fileURLWithPath: "/Users/gouke/Desktop/涌波_動画スライド_v20_20260617-192643/施設の過ごし方動画（涌波）_BGM入り.mp4")
let bgmURL = URL(fileURLWithPath: "/Users/gouke/Projects/plateau-wakunami-hp/video-drafts/gentle-background-melody.caf")

func sine(_ phase: Double) -> Float {
    Float(sin(phase * 2.0 * .pi))
}

func midiToHz(_ note: Int) -> Double {
    440.0 * pow(2.0, Double(note - 69) / 12.0)
}

func smoothStep(_ x: Double) -> Double {
    let t = min(max(x, 0), 1)
    return t * t * (3 - 2 * t)
}

func generateBGM(duration: Double, url: URL) throws {
    try? FileManager.default.removeItem(at: url)
    let sampleRate = 44_100.0
    let channels: AVAudioChannelCount = 2
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: channels, interleaved: false)!
    let file = try AVAudioFile(forWriting: url, settings: format.settings)
    let totalFrames = AVAudioFramePosition(duration * sampleRate)
    let chunkFrames: AVAudioFrameCount = 4096
    let notes = [60, 64, 67, 72, 69, 67, 64, 60, 62, 65, 69, 74, 72, 69, 65, 62]
    let bassNotes = [48, 55, 52, 57]
    var written: AVAudioFramePosition = 0

    while written < totalFrames {
        let frames = AVAudioFrameCount(min(AVAudioFramePosition(chunkFrames), totalFrames - written))
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        let left = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]

        for i in 0..<Int(frames) {
            let absolute = Double(written + AVAudioFramePosition(i))
            let t = absolute / sampleRate

            let noteIndex = Int(t / 2.5) % notes.count
            let noteStart = floor(t / 2.5) * 2.5
            let noteT = t - noteStart
            let melodyHz = midiToHz(notes[noteIndex])
            let melodyEnv = smoothStep(noteT / 0.45) * (1.0 - smoothStep((noteT - 1.8) / 0.7))

            let bassIndex = Int(t / 10.0) % bassNotes.count
            let bassHz = midiToHz(bassNotes[bassIndex])
            let bassEnv = 0.55 + 0.45 * sin((t / 10.0) * 2.0 * .pi)

            let fadeIn = smoothStep(t / 4.0)
            let fadeOut = 1.0 - smoothStep((t - (duration - 6.0)) / 6.0)
            let master = min(fadeIn, fadeOut)

            let melody = Double(sine(t * melodyHz)) * 0.050 * melodyEnv
                + Double(sine(t * melodyHz * 2.0)) * 0.012 * melodyEnv
            let pad = Double(sine(t * bassHz)) * 0.026 * bassEnv
                + Double(sine(t * bassHz * 1.5)) * 0.010
            let shimmer = Double(sine(t * midiToHz(notes[(noteIndex + 4) % notes.count]) * 0.5)) * 0.014

            let sample = Float((melody + pad + shimmer) * master)
            left[i] = sample * 0.92
            right[i] = sample
        }

        try file.write(from: buffer)
        written += AVAudioFramePosition(frames)
    }
}

func makeVideoWithBGM() async throws {
    let sourceAsset = AVURLAsset(url: inputURL)
    let duration = try await sourceAsset.load(.duration)
    let durationSeconds = CMTimeGetSeconds(duration)
    try generateBGM(duration: durationSeconds, url: bgmURL)

    try? FileManager.default.removeItem(at: outputURL)
    let composition = AVMutableComposition()

    guard let sourceVideo = try await sourceAsset.loadTracks(withMediaType: .video).first else {
        throw NSError(domain: "wakunami", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing video track"])
    }
    let compVideo = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    try compVideo.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: sourceVideo, at: .zero)
    compVideo.preferredTransform = try await sourceVideo.load(.preferredTransform)

    var audioMixParams: [AVMutableAudioMixInputParameters] = []

    if let sourceAudio = try await sourceAsset.loadTracks(withMediaType: .audio).first {
        let compAudio = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try compAudio.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: sourceAudio, at: .zero)
        let params = AVMutableAudioMixInputParameters(track: compAudio)
        params.setVolume(1.0, at: .zero)
        audioMixParams.append(params)
    }

    let bgmAsset = AVURLAsset(url: bgmURL)
    guard let bgmTrack = try await bgmAsset.loadTracks(withMediaType: .audio).first else {
        throw NSError(domain: "wakunami", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing BGM track"])
    }
    let compBGM = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    try compBGM.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: bgmTrack, at: .zero)
    let bgmParams = AVMutableAudioMixInputParameters(track: compBGM)
    bgmParams.setVolume(0.13, at: .zero)
    bgmParams.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 0.13, timeRange: CMTimeRange(start: .zero, duration: CMTime(seconds: 4, preferredTimescale: 600)))
    bgmParams.setVolumeRamp(fromStartVolume: 0.13, toEndVolume: 0.0, timeRange: CMTimeRange(start: duration - CMTime(seconds: 5, preferredTimescale: 600), duration: CMTime(seconds: 5, preferredTimescale: 600)))
    audioMixParams.append(bgmParams)

    let audioMix = AVMutableAudioMix()
    audioMix.inputParameters = audioMixParams

    guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
        throw NSError(domain: "wakunami", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create exporter"])
    }
    exporter.outputURL = outputURL
    exporter.outputFileType = .mp4
    exporter.audioMix = audioMix
    await exporter.export()
    if exporter.status != .completed {
        throw exporter.error ?? NSError(domain: "wakunami", code: 4, userInfo: [NSLocalizedDescriptionKey: "Export failed"])
    }
}

try await makeVideoWithBGM()
