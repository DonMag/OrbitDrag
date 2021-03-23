//
//  Extensions.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

extension CGPoint {
	static func pointOnCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
		let x = center.x + radius * cos(angle)
		let y = center.y + radius * sin(angle)
		return CGPoint(x: x, y: y)
	}
}
extension Double {
	var degreesToRadians: Self { self * .pi / 180 }
	var radiansToDegrees: Self { self * 180 / .pi }
}

// MARK: Metric
//	from https://www.swiftbysundell.com/articles/formatting-numbers-in-swift/
//	formats numbers to MAX of 2 decimal places

struct Metric: Codable {
	var name: String
	var value: Double
}

extension Metric: CustomStringConvertible {
	private static var valueFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		return formatter
	}()
	
	var formattedValue: String {
		let number = NSNumber(value: value)
		return Self.valueFormatter.string(from: number)!
	}
	
	var description: String {
		"\(name): \(formattedValue)"
	}
}

