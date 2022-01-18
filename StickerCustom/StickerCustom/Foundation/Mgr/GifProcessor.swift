//
//  GifProcessor.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/3.
//

import Foundation
import UIKit
import MobileCoreServices

class GifProcessor {

    static let shared = GifProcessor()

    private init() { }

    func getGifMessage(from gifPath: String) -> (images: [UIImage]?, duration: Double) {
        guard let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) else { return (nil, -1) }
        guard let gifImageSource = CGImageSourceCreateWithData(gifData as CFData, nil) else { return (nil, -1) }
        let gifImageCount = CGImageSourceGetCount(gifImageSource)
        if gifImageCount == 0 { return (nil, -1) }

        var allImages: [UIImage] = []
        var gifDuration: Double = 0
        for i in 0..<gifImageCount {
            guard let imageRef: CGImage = CGImageSourceCreateImageAtIndex(gifImageSource, i, nil),
                  let imageProperties = CGImageSourceCopyPropertiesAtIndex(gifImageSource, i, nil),
                  let imageInfo = (imageProperties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary
            else { continue }
            let image = UIImage(cgImage: imageRef)
            allImages.append(image)

            if let unclampedDelayTime = imageInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
                gifDuration += unclampedDelayTime.doubleValue
            } else if let delayTime = imageInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                gifDuration += delayTime.doubleValue
            }
        }
        return (allImages, gifDuration)
    }

    func createGif(with allImages: [UIImage], eachDuration: Double, savePath gifPath: String) {
        guard let cfUrl = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath as CFString, CFURLPathStyle.cfurlposixPathStyle, false) else { return }
        // 创建一个图片的目标对象，这个目标对象中描述了构成当前图片目标对象的一系列参数，如图片的URL地址、图片类型、图片帧数、配置参数等
        guard let gifDestination = CGImageDestinationCreateWithURL(cfUrl, kUTTypeGIF, allImages.count, nil) else { return }

        // 为gif图像设置属性（这一步操作必须写在添加每帧图片的前面，否则是无效的，且运行时会有 Error Log）
        let gifDestinationProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyColorModel as String: kCGImagePropertyColorModelRGB, // 图像的颜色模式
                kCGImagePropertyDepth as String: 16, // 图像的颜色深度
                kCGImagePropertyGIFLoopCount as String: 0, // gif 循环次数，0 为无限次循环
                kCGImagePropertyGIFHasGlobalColorMap as String: NSNumber(booleanLiteral: true)
            ]
        ]
        CGImageDestinationSetProperties(gifDestination, gifDestinationProperties as CFDictionary)

        // 添加每帧图片
        let cgImageProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: eachDuration // 每帧之间播放时间，单位是秒
            ]
        ]
        for image in allImages {
            CGImageDestinationAddImage(gifDestination, image.cgImage!, cgImageProperties as CFDictionary)
        }

        // 最后释放目标对象
        CGImageDestinationFinalize(gifDestination)
    }
}
