//: Playground - noun: a place where people can play


import UIKit
import PlaygroundSupport
import CoreImage

PlaygroundPage.current.needsIndefiniteExecution = true

class TrixelatedView: UIView {
  
  let image: AveragableImage?
  var widthRatio: Int
  
  init(image: UIImage, ratio: Int = 15) {
    self.image = (image as! AveragableImage)
    self.widthRatio = ratio
    super.init(frame: CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    self.backgroundColor = UIColor.white
    
    let ratio = self.frame.size.width / self.frame.size.height
    let trixelHeight = self.frame.size.height / CGFloat(self.widthRatio)
    let trixelWidth = trixelHeight * ratio
    let columns = (self.frame.size.width / trixelWidth) + 1
    let rows = (self.frame.size.height / trixelHeight) + 1
    
    let context = UIGraphicsGetCurrentContext()
    
    for column in 0 ..< Int(columns) {
      let baseX = CGFloat(column) * trixelWidth
      
      for row in 0 ..< Int(rows) {
        let offset = CGFloat(column).truncatingRemainder(dividingBy: 2.0) == 0 ? 0.0 : -0.5 as CGFloat
        let baseY = CGFloat(row) * trixelHeight + (trixelHeight * offset)
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 1.0
        bezierPath.move(to: CGPoint(x: baseX, y: baseY ))
        bezierPath.addLine(to: CGPoint(x: baseX + trixelWidth,
                                       y: (baseY - (trixelHeight * 0.5))))
        bezierPath.addLine(to: CGPoint(x: baseX + trixelWidth,
                                       y: (baseY + (trixelHeight * 0.5))))
        bezierPath.close()
        let fromRect = bezierPath.bounds
        
        if let drawImage = self.image?.cgImage!.cropping(to: fromRect) {
          let bimage = AveragableImage(cgImage: drawImage)
          let averageColour = bimage.averageColor().cgColor
          context?.setFillColor(averageColour)
          context?.setStrokeColor(averageColour)
          context?.setShouldAntialias(true)
          bezierPath.stroke()
          bezierPath.fill()
        }
        
        let bezierPathB = UIBezierPath()
        bezierPathB.lineWidth = 1.0
        bezierPathB.move(to: CGPoint(x: baseX, y: baseY))
        bezierPathB.addLine(to: CGPoint(x: baseX + trixelWidth,
                                        y: (baseY + trixelHeight * 0.5)))
        bezierPathB.addLine(to: CGPoint(x: baseX,
                                        y: (baseY + trixelHeight)))
        bezierPathB.close()
        let fromRectB = bezierPathB.bounds
        if let drawImageB = self.image?.cgImage!.cropping(to: fromRectB) {
          let cimage = AveragableImage(cgImage: drawImageB)
          let averageColourB = cimage.averageColor().cgColor
          context?.setFillColor(averageColourB)
          context?.setStrokeColor(averageColourB)
          context?.setShouldAntialias(true)
          bezierPathB.stroke()
          bezierPathB.fill()
        }
      }
    }
  }
}

extension UIView {
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
  }
}

class AveragableImage: UIImage {
  func averageColor() -> UIColor {
    let rgba = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let context: CGContext = CGContext(data: rgba, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: info.rawValue)!
    context.draw(self.cgImage!, in: CGRect(x:0, y:0, width:1, height:1))
    
    if rgba[3] > 0 {
      let alpha: CGFloat = CGFloat(rgba[3]) / 255.0
      let multiplier: CGFloat = alpha / 255.0
      return UIColor(red: CGFloat(rgba[0]) * multiplier, green: CGFloat(rgba[1]) * multiplier, blue: CGFloat(rgba[2]) * multiplier, alpha: alpha)
    } else {
      return UIColor(red: CGFloat(rgba[0]) / 255.0, green: CGFloat(rgba[1]) / 255.0, blue: CGFloat(rgba[2]) / 255.0, alpha: CGFloat(rgba[3]) / 255.0)
    }
  }
}

func currentDateTimeAsString() -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "dd-MM-yy|hh.mm.ss"
  return dateFormatter.string(from: Date())
}

func guidAsString() -> String {
    let guid = UUID.init().uuidString
    return guid
}

func trixelate(imageAtURL url: URL) -> UIImage? {
  do {
    let data = try Data(contentsOf: url)
    if let image = AveragableImage(data: data) {
      let trixelTest = TrixelatedView(image: image, ratio: 10)
      let filteredTrixel = applyFilters(to: trixelTest.asImage())
      return filteredTrixel
    }
  } catch {
    // Fail case empty
  }
  return nil
}

func applyFilters(to image: UIImage) -> UIImage {
    let context = CIContext()
    context
    if let coreImage = CIImage(image: image) {
        let croppingRect = CGRect(x: 80, y: 80, width: (coreImage.extent.width - 160), height: (coreImage.extent.height - 160)) //Gaussian blur reduces the image size, by a predictable value, which adds a white border which I don't want.
        let randomCoreImage =  cropFilter(from: coreImage.extent, to: noiseFilter()!)
        //TODO: switch the blur radius based on source image size
        if let filteredCoreImage = blurFilter(on: coreImage, radius: 10),
           let blendedCoreImage = blendFilter(foreground: randomCoreImage!, background: filteredCoreImage),
           let croppedBlendedCoreImage = cropFilter(from: croppingRect, to: blendedCoreImage),
           let filteredCGImage = context.createCGImage(croppedBlendedCoreImage, from: croppedBlendedCoreImage.extent) {
             return UIImage(cgImage: filteredCGImage)
        }
    }
    return image
}

func cropFilter(from rect: CGRect, to: CIImage) -> CIImage? {
  if let filter = CIFilter(name: "CICrop", withInputParameters: ["inputImage": to, "inputRectangle":rect]) {
    return filter.value(forKey: "outputImage") as? CIImage
  }
  return nil
}

func blurFilter(on image: CIImage, radius: Double) -> CIImage? {
  if let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputImage" : image, "inputRadius": radius]) {
    return filter.value(forKey: "outputImage") as? CIImage
  }
  return nil
}

func noiseFilter() -> CIImage? {
  let filter = CIFilter(name: "CIRandomGenerator")
  return filter?.value(forKey: "outputImage") as? CIImage
}

func blendFilter(foreground: CIImage, background: CIImage) -> CIImage? {
  if let blend = CIFilter(name: "CIOverlayBlendMode", withInputParameters: ["inputImage": foreground,
                                                                            "inputBackgroundImage": background]) {
    return blend.value(forKey: "outputImage") as? CIImage
  }
  return nil
}

func processSharedDataForPlayground() {
  let rootPath = playgroundSharedDataDirectory.appendingPathComponent("Trixelated")
  let sourcePath = rootPath.appendingPathComponent("Source")
  do {
    let paths = try FileManager.default.contentsOfDirectory(atPath: sourcePath.path)
    for path in paths {
      let pathURL = sourcePath.appendingPathComponent(path)
      if let trixellatedImage = trixelate(imageAtURL: pathURL) {
        let guidString = guidAsString().appending(".jpg")
        let newPath = rootPath.appendingPathComponent(guidString)
        let imageData = UIImageJPEGRepresentation(trixellatedImage, 0.5)
        try! imageData?.write(to: newPath, options: .noFileProtection)
      }
    }
  } catch  {
    // Fail case empty
  }
  PlaygroundPage.current.finishExecution()
}

processSharedDataForPlayground()







