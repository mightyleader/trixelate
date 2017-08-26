//: Playground - noun: a place where people can play

import UIKit
import Foundation
import PlaygroundSupport

class TrixelatedView: UIView {

	let image: UIImage?

	init(image: UIImage) {
		self.image = image
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
    

		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(UIColor.blue.cgColor)
		let bezierPath = UIBezierPath()
		bezierPath.move(to: self.frame.origin)

		bezierPath.addLine(to: CGPoint(x: trixelWidth, y: (trixelHeight * 0.5) * -1))
		bezierPath.addLine(to: CGPoint(x: trixelWidth, y: (trixelHeight * 0.5)))
		bezierPath.close()
		bezierPath.stroke()
		bezierPath.fill()
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
let vector = CIVector(cgRect: CGRect(x: 0, y: 518, width: 10, height: 10))
let color = image?.areaAverage(in: vector)
let trixelTest = TrixelatedView(image: image!)
trixelTest.backgroundColor = color


