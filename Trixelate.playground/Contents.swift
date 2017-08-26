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
		let trixelHeight = Float(self.frame.size.height / 7)
		let trixelWidth = Float(trixelHeight) * Float(ratio)
    let columns = Float(self.frame.size.width) / trixelWidth
    let rows = Float(self.frame.size.height) / trixelHeight

		let context = UIGraphicsGetCurrentContext()
		
    for column in 0 ..< Int(columns) {
      let baseX = Float(column) * Float(trixelWidth)
      
      let offset = Float(column).truncatingRemainder(dividingBy: Float(2.0)) == 0 ? Float(0.5) : Float(1.0)
      
      //Float(column) % 2 > 0 ? Float(0.5) : Float(1) //Float(modf(Float(column)).0 > 0 ? 0.5 : 1)
      for row in 0 ..< Int(rows) {
        let baseY = Float(row) * Float(trixelHeight)
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: CGFloat(baseX), y: CGFloat(baseY)))
        bezierPath.addLine(to: CGPoint(x: CGFloat(baseX + trixelWidth),
                                       y: CGFloat(baseY - (trixelHeight * offset))))
        bezierPath.addLine(to: CGPoint(x: CGFloat(baseX + trixelWidth),
                                       y: CGFloat(baseY + (trixelHeight * offset))))
        bezierPath.close()
        bezierPath.stroke()
        let vector = CIVector(cgRect: CGRect(x: CGFloat(baseX + trixelWidth * offset),
                                             y: CGFloat(baseY),
                                             width: CGFloat(trixelWidth),
                                             height: CGFloat(trixelHeight)))
        let averageColour = self.image?.areaAverage(in: vector)
        context?.setFillColor((averageColour?.cgColor)!)
        bezierPath.fill()
        
        let bezierPathB = UIBezierPath()
        bezierPathB.move(to: CGPoint(x: CGFloat(baseX), y: CGFloat(baseY)))
        bezierPathB.addLine(to: CGPoint(x: CGFloat(baseX),
                                       y: CGFloat(baseY + trixelHeight)))
        bezierPathB.addLine(to: CGPoint(x: CGFloat(baseX + trixelWidth),
                                       y: CGFloat(baseY + (trixelHeight * offset))))
        bezierPathB.close()
        bezierPathB.stroke()
        let vectorB = CIVector(cgRect: CGRect(x: CGFloat(baseX + trixelWidth * offset),
                                             y: CGFloat(baseY),
                                             width: CGFloat(trixelWidth),
                                             height: CGFloat(trixelHeight)))
        let averageColourB = self.image?.areaAverage(in: vectorB)
        context?.setFillColor((averageColourB?.cgColor)!)
        bezierPathB.fill()
      }
    }
	}
}

class AveragableImage: UIImage {
  
	func areaAverage(in vector: CIVector) -> UIColor {
		var bitmap = [UInt8](repeating: 0, count: 4)
		// Get average color.
		let context = CIContext()
		let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
		let inputExtent = vector
		let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
		let outputImage = filter.outputImage!
		let outputExtent = outputImage.extent
		assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
		// Render to bitmap.
		context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
		// Compute result.
		let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
		return result
	}
}

guard let fileUrl = Bundle.main.url(forResource: "IMG_3730", withExtension: "JPG") else { fatalError() }
let data = try Data(contentsOf: fileUrl)
let image = AveragableImage(data: data)
let trixelTest = TrixelatedView(image: image!)



