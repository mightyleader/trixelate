//: Playground - noun: a place where people can play

import UIKit
import Foundation
import PlaygroundSupport

class TrixelatedView: UIView {

	let image: AveragableImage?

	init(image: UIImage) {
    self.image = (image as! AveragableImage)
		super.init(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func draw(_ rect: CGRect) {
		self.backgroundColor = UIColor.white

		let ratio = self.frame.size.width / self.frame.size.height
		let trixelHeight = self.frame.size.height / 30
		let trixelWidth = trixelHeight * ratio
    let columns = self.frame.size.width / trixelWidth
    let rows = self.frame.size.height / trixelHeight

		let context = UIGraphicsGetCurrentContext()
		
    for column in 0 ..< Int(columns) {
      let baseX = CGFloat(column) * trixelWidth
    
      for row in 0 ..< Int(rows) {
        let offset = CGFloat(column).truncatingRemainder(dividingBy: 2.0) == 0 ? 0.0 : -0.5 as CGFloat
        let baseY = CGFloat(row) * trixelHeight + (trixelHeight * offset)
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 0.0
        bezierPath.move(to: CGPoint(x: baseX, y: baseY ))
        bezierPath.addLine(to: CGPoint(x: baseX + trixelWidth,
                                       y: (baseY - (trixelHeight * 0.5))))
        bezierPath.addLine(to: CGPoint(x: baseX + trixelWidth,
                                       y: (baseY + (trixelHeight * 0.5))))
        bezierPath.close()
        bezierPath.stroke()
        let fromRect = CGRect(x: CGFloat(baseX + trixelWidth * 0.5),
                            y: CGFloat(baseY),
                            width: CGFloat(trixelWidth),
                            height: CGFloat(trixelHeight))
        let drawImage = self.image?.cgImage!.cropping(to: fromRect)
        let bimage = AveragableImage(cgImage: drawImage!)
        let averageColour = bimage.averageColor().cgColor //areaAverage(in: vector).cgColor //= UIColor.blue.cgColor//
        context?.setFillColor(averageColour)
        bezierPath.fill()
        
        let bezierPathB = UIBezierPath()
        bezierPathB.lineWidth = 0.0
        bezierPathB.move(to: CGPoint(x: baseX, y: baseY))
        bezierPathB.addLine(to: CGPoint(x: baseX + trixelWidth,
                                        y: (baseY + trixelHeight * 0.5)))
        bezierPathB.addLine(to: CGPoint(x: baseX,
                                        y: (baseY + trixelHeight)))
        bezierPathB.close()
        bezierPathB.stroke()
        let fromRectB = CGRect(x: CGFloat(baseX + trixelWidth * 0.5),
                             y: CGFloat(baseY),
                             width: CGFloat(trixelWidth),
                             height: CGFloat(trixelHeight))
        let drawImageB = self.image?.cgImage!.cropping(to: fromRectB)
        let cimage = AveragableImage(cgImage: drawImageB!)
        let averageColourB = cimage.averageColor().cgColor //areaAverage(in: vector).cgColor //= UIColor.blue.cgColor//
        context?.setFillColor(averageColourB)
        bezierPathB.fill()
      }
    }
	}
}

class AveragableImage: UIImage {
  
  convenience init(view: UIView) {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: (image?.cgImage)!)
  }
  
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


guard let fileUrl = Bundle.main.url(forResource: "MRS_6459schukar2048", withExtension: "jpg") else { fatalError() }
let data = try Data(contentsOf: fileUrl)
let image = AveragableImage(data: data)
let trixelTest = TrixelatedView(image: image!)
let trixellatedImage = AveragableImage(view: trixelTest)



