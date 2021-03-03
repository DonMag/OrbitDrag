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
