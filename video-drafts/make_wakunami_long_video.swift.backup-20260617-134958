import AppKit
import AVFoundation
import CoreImage
import Foundation
import Vision

struct Scene {
    let imageName: String?
    let title: String
    let subtitle: String
    let seconds: Double
    let rotateDegrees: CGFloat
}

let imageDir = URL(fileURLWithPath: "/tmp/codex-wakunami-docx-media")
let outDir = URL(fileURLWithPath: "/Users/gouke/Projects/plateau-wakunami-hp/video-drafts")
let editedDir = outDir.appendingPathComponent("edited-photos")
let aiDir = outDir.appendingPathComponent("ai-assets")
let videoOnlyURL = outDir.appendingPathComponent("wakunami-long-draft-v15-template-video-only.mp4")
let finalURL = outDir.appendingPathComponent("wakunami-long-draft-v15-template.mov")
let narrationURL = outDir.appendingPathComponent("wakunami-long-narration.m4a")

let width = 1920
let height = 1080
let frameSize = NSSize(width: width, height: height)

let scenes: [Scene] = [
    Scene(imageName: "wakunami-exterior-real.png", title: "涌波の外観", subtitle: "まずは、どのような場所に通うのかを見ていただきます。", seconds: 8, rotateDegrees: 0),
    Scene(imageName: "09-relax-room-clean.jpg", title: "建物の中の様子", subtitle: "落ち着いて過ごせるフロアで、一日を始めます。", seconds: 8, rotateDegrees: 0),
    Scene(imageName: "wakunami-pickup-real.png", title: "到着", subtitle: "送迎で到着されたら、職員がそばでお手伝いします。", seconds: 8, rotateDegrees: 0),
    Scene(imageName: "health-check-hands-ai.png", title: "健康確認", subtitle: "血圧や体調を確認し、その日の状態に合わせて過ごします。", seconds: 9, rotateDegrees: 0),
    Scene(imageName: "wakunami-footbath-real.png", title: "電気による足湯", subtitle: "体を温め、代謝や免疫力の維持をサポートします。", seconds: 8, rotateDegrees: 0),
    Scene(imageName: "waterbed-supine-no-face-ai.png", title: "ウォーターベッド", subtitle: "横になって、落ち着いて体を休める時間もあります。", seconds: 8, rotateDegrees: 0),
    Scene(imageName: "medomer-reference-no-face-ai.png", title: "メドマー", subtitle: "脚をやさしく包み、リラクゼーションの時間を過ごせます。", seconds: 8, rotateDegrees: 0),
    Scene(imageName: "walking-training-no-face-ai.png", title: "個別運動", subtitle: "一人ひとりの状態に合わせて、動きやすい体づくりを行います。", seconds: 10, rotateDegrees: 0),
    Scene(imageName: "walking-training-no-face-ai.png", title: "歩行練習", subtitle: "安全に配慮しながら、動作や歩行の確認も行います。", seconds: 8, rotateDegrees: 0),
    Scene(imageName: "group-exercise-no-face-ai.png", title: "集団運動", subtitle: "みんなで体を動かし、筋力や体力の維持を目指します。", seconds: 10, rotateDegrees: 0),
    Scene(imageName: "wakunami-bath-real.png", title: "入浴", subtitle: "希望や状態に応じて、入浴も利用できます。", seconds: 9, rotateDegrees: 0),
    Scene(imageName: "lunch-table-no-face-ai.png", title: "昼食", subtitle: "昼食は、落ち着いて食べられる時間にしています。", seconds: 9, rotateDegrees: 0),
    Scene(imageName: "wakunami-mahjong-real.png", title: "趣味活動", subtitle: "麻雀など、好きなことを楽しむ時間もあります。", seconds: 8, rotateDegrees: 0),
    Scene(imageName: "wakunami-brain-training-real.png", title: "脳トレ", subtitle: "みんなで考えたり声を出したりして、気分をリフレッシュします。", seconds: 10, rotateDegrees: 0),
    Scene(imageName: nil, title: "大きなレクリエーション", subtitle: "時々、普段と違う活動を行い、楽しみながら機能訓練の成果を確認します。", seconds: 10, rotateDegrees: 0),
    Scene(imageName: "wakunami-sendoff-real.png", title: "帰りの送り出し", subtitle: "一日の終わりは、職員が笑顔でお送りします。", seconds: 9, rotateDegrees: 0),
    Scene(imageName: "wakunami-exterior-real.png", title: "見学だけでも大丈夫です", subtitle: "涌波のホームページから、施設の様子をご確認ください。\ntomogouke-lang.github.io/plateau-wakunami-hp/", seconds: 10, rotateDegrees: 0),
]

func loadImage(_ scene: Scene) -> NSImage? {
    guard let name = scene.imageName else { return nil }
    let candidates = [
        aiDir.appendingPathComponent(name),
        editedDir.appendingPathComponent(name),
        imageDir.appendingPathComponent(name),
    ]
    guard let url = candidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }),
          let image = NSImage(contentsOf: url) else { return nil }
    if scene.rotateDegrees == 0 { return image }
    let radians = scene.rotateDegrees * .pi / 180
    let old = image.size
    let newSize = scene.rotateDegrees.truncatingRemainder(dividingBy: 180) == 0 ? old : NSSize(width: old.height, height: old.width)
    let rotated = NSImage(size: newSize)
    rotated.lockFocus()
    let transform = NSAffineTransform()
    transform.translateX(by: newSize.width / 2, yBy: newSize.height / 2)
    transform.rotate(byRadians: radians)
    transform.translateX(by: -old.width / 2, yBy: -old.height / 2)
    transform.concat()
    image.draw(in: NSRect(origin: .zero, size: old))
    rotated.unlockFocus()
    return rotated
}

func aspectFill(_ source: NSSize, into target: NSSize) -> NSRect {
    let scale = max(target.width / source.width, target.height / source.height)
    let size = NSSize(width: source.width * scale, height: source.height * scale)
    return NSRect(x: (target.width - size.width) / 2, y: (target.height - size.height) / 2, width: size.width, height: size.height)
}

func aspectFit(_ source: NSSize, into target: NSSize) -> NSRect {
    let scale = min(target.width / source.width, target.height / source.height)
    let size = NSSize(width: source.width * scale, height: source.height * scale)
    return NSRect(x: (target.width - size.width) / 2, y: (target.height - size.height) / 2, width: size.width, height: size.height)
}

func drawWrappedText(_ text: String, rect: NSRect, font: NSFont, color: NSColor, alignment: NSTextAlignment = .left) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.lineSpacing = 6
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph,
    ]
    (text as NSString).draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attrs)
}

func detectFaces(in image: NSImage) -> [CGRect] {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let cg = bitmap.cgImage else { return [] }
    let request = VNDetectFaceRectanglesRequest()
    let handler = VNImageRequestHandler(cgImage: cg, orientation: .up, options: [:])
    try? handler.perform([request])
    return request.results?.map { $0.boundingBox } ?? []
}

func renderScene(_ scene: Scene) -> NSImage {
    let canvas = NSImage(size: frameSize)
    canvas.lockFocus()
    NSColor(calibratedRed: 0.94, green: 0.95, blue: 0.92, alpha: 1).setFill()
    NSRect(origin: .zero, size: frameSize).fill()

    if let image = loadImage(scene) {
        let photoRect = aspectFit(image.size, into: NSSize(width: 1500, height: 800))
            .offsetBy(dx: (frameSize.width - 1500) / 2, dy: 170)
        NSColor(calibratedRed: 0.88, green: 0.89, blue: 0.85, alpha: 1).setFill()
        NSBezierPath(roundedRect: photoRect.insetBy(dx: -18, dy: -18), xRadius: 4, yRadius: 4).fill()
        image.draw(in: photoRect, from: .zero, operation: .sourceOver, fraction: 1)
    } else {
        NSColor(calibratedRed: 0.76, green: 0.82, blue: 0.76, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: 210, y: 270, width: 1500, height: 560), xRadius: 4, yRadius: 4).fill()
        drawWrappedText(scene.title, rect: NSRect(x: 300, y: 545, width: 1320, height: 80), font: NSFont.boldSystemFont(ofSize: 58), color: NSColor(calibratedRed: 0.06, green: 0.18, blue: 0.16, alpha: 1), alignment: .center)
        drawWrappedText(scene.subtitle, rect: NSRect(x: 370, y: 430, width: 1180, height: 110), font: NSFont.systemFont(ofSize: 34), color: NSColor(calibratedRed: 0.06, green: 0.18, blue: 0.16, alpha: 0.9), alignment: .center)
    }

    NSColor(calibratedRed: 0.08, green: 0.20, blue: 0.18, alpha: 0.88).setFill()
    NSRect(x: 0, y: 0, width: frameSize.width, height: 150).fill()
    drawWrappedText(scene.title, rect: NSRect(x: 120, y: 80, width: 1680, height: 50), font: NSFont.boldSystemFont(ofSize: 38), color: .white)
    drawWrappedText(scene.subtitle, rect: NSRect(x: 120, y: 22, width: 1680, height: 58), font: NSFont.systemFont(ofSize: 28), color: NSColor(calibratedWhite: 1, alpha: 0.94))
    canvas.unlockFocus()
    return canvas
}

func pixelBuffer(from image: NSImage, pool: CVPixelBufferPool?) -> CVPixelBuffer {
    var buffer: CVPixelBuffer?
    let status: CVReturn
    if let pool {
        status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
    } else {
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        ]
        status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs as CFDictionary, &buffer)
    }
    guard status == kCVReturnSuccess, let pixelBuffer = buffer else {
        fatalError("CVPixelBufferCreate failed: \(status)")
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, [])
    let context = CGContext(
        data: CVPixelBufferGetBaseAddress(pixelBuffer),
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    image.draw(in: NSRect(x: 0, y: 0, width: width, height: height))
    NSGraphicsContext.restoreGraphicsState()
    CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
    return pixelBuffer
}

func makeVideoOnly() throws {
    try? FileManager.default.removeItem(at: videoOnlyURL)
    let writer = try AVAssetWriter(outputURL: videoOnlyURL, fileType: .mp4)
    let settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: width,
        AVVideoHeightKey: height,
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
    ])
    writer.add(input)
    guard writer.startWriting() else {
        throw writer.error ?? NSError(domain: "wakunami", code: 10, userInfo: [NSLocalizedDescriptionKey: "Writer could not start"])
    }
    writer.startSession(atSourceTime: .zero)

    var t = CMTime.zero
    for scene in scenes {
        while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.05) }
        if !adaptor.append(pixelBuffer(from: renderScene(scene), pool: adaptor.pixelBufferPool), withPresentationTime: t) {
            fputs("Append failed at \(scene.title): \(String(describing: writer.error))\n", stderr)
            exit(1)
        }
        t = t + CMTime(seconds: scene.seconds, preferredTimescale: 600)
    }
    if !adaptor.append(pixelBuffer(from: renderScene(scenes.last!), pool: adaptor.pixelBufferPool), withPresentationTime: t) {
        fputs("Append failed at final frame: \(String(describing: writer.error))\n", stderr)
        exit(1)
    }
    writer.endSession(atSourceTime: t)
    input.markAsFinished()
    writer.finishWriting {
        if writer.status != .completed {
            fputs("Video writer failed: \(String(describing: writer.error))\n", stderr)
            exit(1)
        }
        exit(0)
    }
    RunLoop.current.run()
}

func muxAudio() async throws {
    try? FileManager.default.removeItem(at: finalURL)
    let composition = AVMutableComposition()
    let videoAsset = AVURLAsset(url: videoOnlyURL)
    let audioAsset = AVURLAsset(url: narrationURL)

    guard let videoTrack = try await videoAsset.loadTracks(withMediaType: .video).first,
          let audioTrack = try await audioAsset.loadTracks(withMediaType: .audio).first else {
        throw NSError(domain: "wakunami", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing video or audio track"])
    }

    let videoDuration = try await videoAsset.load(.duration)
    let audioDuration = try await audioAsset.load(.duration)
    let duration = min(videoDuration, audioDuration)

    let compVideo = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    try compVideo.insertTimeRange(CMTimeRange(start: .zero, duration: videoDuration), of: videoTrack, at: .zero)
    let compAudio = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    try compAudio.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: audioTrack, at: .zero)

    guard let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) else {
        throw NSError(domain: "wakunami", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create exporter"])
    }
    export.outputURL = finalURL
    export.outputFileType = .mov
    await export.export()
    if export.status != .completed {
        throw export.error ?? NSError(domain: "wakunami", code: 3, userInfo: [NSLocalizedDescriptionKey: "Export failed"])
    }
}

let mode = CommandLine.arguments.dropFirst().first ?? "video"
if mode == "video" {
    try makeVideoOnly()
} else if mode == "mux" {
    try await muxAudio()
} else {
    fputs("Usage: swift make_wakunami_long_video.swift [video|mux]\n", stderr)
    exit(2)
}
