import AppKit
import CoreImage
import Vision
import Foundation

struct PhotoConfig {
    let input: String
    let output: String
    let note: String
    let rotate: CGFloat
    let brightness: Float
    let contrast: Float
    let saturation: Float
    let privacyBlur: Bool
}

let sourceDir = URL(fileURLWithPath: "/tmp/codex-wakunami-docx-media")
let outputDir = URL(fileURLWithPath: "/Users/gouke/Projects/plateau-wakunami-hp/video-drafts/edited-photos")
try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

let configs: [PhotoConfig] = [
    PhotoConfig(input: "image1.jpeg", output: "01-building-clean.jpg", note: "建物。ひび割れが目立つため、やや明るくして中央寄せ。生成AIでの外壁修正候補。", rotate: 0, brightness: 0.06, contrast: 1.08, saturation: 1.03, privacyBlur: false),
    PhotoConfig(input: "image3.png", output: "02-pickup-clean.jpg", note: "送迎。元写真にブレあり。明るさ補正。必要ならAI手ぶれ補正候補。", rotate: 0, brightness: 0.05, contrast: 1.08, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image4.jpeg", output: "03-health-check-clean.jpg", note: "健康確認。顔と背景情報に注意。", rotate: 0, brightness: 0.08, contrast: 1.10, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image2.jpeg", output: "04-group-exercise-clean.jpg", note: "集団運動。暗さ補正。人物は小さく見せる。", rotate: 0, brightness: 0.10, contrast: 1.12, saturation: 1.03, privacyBlur: true),
    PhotoConfig(input: "image8.jpeg", output: "05-individual-exercise-clean.jpg", note: "個別運動。顔・背景に注意。", rotate: 0, brightness: 0.06, contrast: 1.08, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image9.jpeg", output: "06-walking-training-clean.jpg", note: "歩行練習。上下左右の向き補正。", rotate: 90, brightness: 0.06, contrast: 1.08, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image10.jpeg", output: "07-walking-training-2-clean.jpg", note: "歩行練習。上下左右の向き補正。", rotate: 90, brightness: 0.08, contrast: 1.10, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image5.jpeg", output: "08-footbath-clean.jpg", note: "足湯。顔が近いため公開時は同意確認。", rotate: 0, brightness: 0.07, contrast: 1.08, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image6.jpeg", output: "09-relax-room-clean.jpg", note: "リラクゼーション全景。暗さ補正。", rotate: 0, brightness: 0.09, contrast: 1.12, saturation: 1.03, privacyBlur: true),
    PhotoConfig(input: "image7.jpeg", output: "10-waterbed-clean.jpg", note: "ウォーターベッド・メドマー。顔が見えるため公開時注意。", rotate: 0, brightness: 0.07, contrast: 1.10, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image13.jpeg", output: "11-bath-clean.jpg", note: "入浴設備。人物なし。使いやすい。", rotate: 0, brightness: 0.10, contrast: 1.10, saturation: 1.02, privacyBlur: false),
    PhotoConfig(input: "image14.jpeg", output: "12-lunch-clean.jpg", note: "昼食。顔・背景に注意。", rotate: 0, brightness: 0.08, contrast: 1.10, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image15.jpeg", output: "13-lunch-support-clean.jpg", note: "食事見守り。向き補正。", rotate: 90, brightness: 0.08, contrast: 1.10, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image16.jpeg", output: "14-recreation-clean.jpg", note: "レクリエーション。顔・背景に注意。", rotate: 0, brightness: 0.08, contrast: 1.10, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image17.jpeg", output: "15-hobby-clean.jpg", note: "趣味活動。手元中心で使える。", rotate: 0, brightness: 0.08, contrast: 1.10, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image18.jpeg", output: "16-brain-training-clean.jpg", note: "脳トレ。顔・背景に注意。", rotate: 0, brightness: 0.08, contrast: 1.10, saturation: 1.02, privacyBlur: true),
    PhotoConfig(input: "image19.jpeg", output: "17-event-clean.jpg", note: "大きなレクリエーション。顔出し同意が取れるなら強い素材。", rotate: 0, brightness: 0.08, contrast: 1.10, saturation: 1.03, privacyBlur: true),
    PhotoConfig(input: "image20.png", output: "18-staff-clean.jpg", note: "スタッフ写真。採用向け候補。スタッフ本人の同意確認が必要。", rotate: 0, brightness: 0.06, contrast: 1.08, saturation: 1.03, privacyBlur: false),
]

let ciContext = CIContext(options: nil)

func rotated(_ image: NSImage, degrees: CGFloat) -> NSImage {
    if degrees == 0 { return image }
    let radians = degrees * .pi / 180
    let old = image.size
    let newSize = degrees.truncatingRemainder(dividingBy: 180) == 0 ? old : NSSize(width: old.height, height: old.width)
    let result = NSImage(size: newSize)
    result.lockFocus()
    let transform = NSAffineTransform()
    transform.translateX(by: newSize.width / 2, yBy: newSize.height / 2)
    transform.rotate(byRadians: radians)
    transform.translateX(by: -old.width / 2, yBy: -old.height / 2)
    transform.concat()
    image.draw(in: NSRect(origin: .zero, size: old))
    result.unlockFocus()
    return result
}

func enhanced(_ image: NSImage, brightness: Float, contrast: Float, saturation: Float) -> NSImage {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let cg = bitmap.cgImage else { return image }
    let ci = CIImage(cgImage: cg)
    let filter = CIFilter(name: "CIColorControls")!
    filter.setValue(ci, forKey: kCIInputImageKey)
    filter.setValue(brightness, forKey: kCIInputBrightnessKey)
    filter.setValue(contrast, forKey: kCIInputContrastKey)
    filter.setValue(saturation, forKey: kCIInputSaturationKey)
    guard let output = filter.outputImage,
          let outCG = ciContext.createCGImage(output, from: ci.extent) else { return image }
    return NSImage(cgImage: outCG, size: image.size)
}

func detectFaces(in image: NSImage) -> [CGRect] {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let cg = bitmap.cgImage else { return [] }
    let req = VNDetectFaceRectanglesRequest()
    let handler = VNImageRequestHandler(cgImage: cg, orientation: .up, options: [:])
    try? handler.perform([req])
    return req.results?.map { $0.boundingBox } ?? []
}

func aspectFill(_ source: NSSize, into target: NSSize) -> NSRect {
    let scale = max(target.width / source.width, target.height / source.height)
    let size = NSSize(width: source.width * scale, height: source.height * scale)
    return NSRect(x: (target.width - size.width) / 2, y: (target.height - size.height) / 2, width: size.width, height: size.height)
}

func blurred(_ image: NSImage, radius: Double) -> NSImage {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let cg = bitmap.cgImage else { return image }
    let ci = CIImage(cgImage: cg)
    let filter = CIFilter(name: "CIGaussianBlur")!
    filter.setValue(ci.clampedToExtent(), forKey: kCIInputImageKey)
    filter.setValue(radius, forKey: kCIInputRadiusKey)
    guard let output = filter.outputImage?.cropped(to: ci.extent),
          let outCG = ciContext.createCGImage(output, from: ci.extent) else { return image }
    return NSImage(cgImage: outCG, size: image.size)
}

func render(_ source: NSImage, privacyBlur: Bool) -> (NSImage, Int) {
    let canvasSize = NSSize(width: 1920, height: 1080)
    let canvas = NSImage(size: canvasSize)
    let fillRect = aspectFill(source.size, into: canvasSize)
    let faces = privacyBlur ? detectFaces(in: source) : []
    let blurredSource = faces.isEmpty ? nil : blurred(source, radius: 24)

    canvas.lockFocus()
    NSColor.white.setFill()
    NSRect(origin: .zero, size: canvasSize).fill()
    source.draw(in: fillRect, from: .zero, operation: .sourceOver, fraction: 1)

    if let blurredSource {
        for face in faces {
            let x = fillRect.minX + face.minX * fillRect.width
            let y = fillRect.minY + face.minY * fillRect.height
            let w = face.width * fillRect.width
            let h = face.height * fillRect.height
            let pad = max(w, h) * 0.45
            let clip = NSRect(x: x - pad / 2, y: y - pad / 2, width: w + pad, height: h + pad)
            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(roundedRect: clip, xRadius: 18, yRadius: 18).addClip()
            blurredSource.draw(in: fillRect, from: .zero, operation: .sourceOver, fraction: 1)
            NSGraphicsContext.restoreGraphicsState()
        }
    }
    canvas.unlockFocus()
    return (canvas, faces.count)
}

func writeJPEG(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.90]) else {
        throw NSError(domain: "process_photos", code: 1)
    }
    try data.write(to: url)
}

var report = "# 写真加工 第1段階レポート\n\n"
report += "生成先: `video-drafts/edited-photos/`\n\n"
report += "| 出力 | 処理 | 顔検出 | コメント |\n"
report += "|---|---|---:|---|\n"

for config in configs {
    let inputURL = sourceDir.appendingPathComponent(config.input)
    guard let raw = NSImage(contentsOf: inputURL) else { continue }
    let fixed = enhanced(rotated(raw, degrees: config.rotate), brightness: config.brightness, contrast: config.contrast, saturation: config.saturation)
    let (rendered, faceCount) = render(fixed, privacyBlur: config.privacyBlur)
    let outputURL = outputDir.appendingPathComponent(config.output)
    try writeJPEG(rendered, to: outputURL)
    let process = [
        config.rotate == 0 ? nil : "向き補正",
        "明るさ補正",
        "16:9化",
        config.privacyBlur ? "顔の自然ぼかし候補" : nil
    ].compactMap { $0 }.joined(separator: " / ")
    report += "| \(config.output) | \(process) | \(faceCount) | \(config.note) |\n"
}

try report.write(to: outputDir.appendingPathComponent("processing-report.md"), atomically: true, encoding: .utf8)
print(outputDir.path)
