//
//  ViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class ViewController: UIViewController {

	let numMoons: Int = 12
	
	let planetRadius: CGFloat = 80
	lazy var moonPathRadius: CGFloat = planetRadius * 1.75
	let firstScale: CGFloat = 0.60
	
	var moonViews: [RoundView] = []
	var activeMoon: RoundView!

	var animator = UIViewPropertyAnimator()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		for i in 1...numMoons {
			let v = RoundView()
			v.label.text = "\(i)"
			view.addSubview(v)
			moonViews.append(v)
		}

		guard let v = moonViews.last else {
			fatalError("We didn't add any Moons!")
		}
		activeMoon = v
		
		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
		view.addGestureRecognizer(panRecognizer)

	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if moonViews.first?.frame.origin.x == 0 {
			planetCenter = view.center
			moonViews.forEach { moon in
				moon.frame = CGRect(origin: .zero, size: CGSize(width: planetRadius * 2.0, height: planetRadius * 2.0))
				moon.center = planetCenter
			}
		}
	}
	
	var planetCenter: CGPoint = .zero
	var startPos: CGPoint = .zero
	
	@objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
		guard let idx = moonViews.firstIndex(of: activeMoon),
			  idx > 0
		else {
			return
		}
		switch recognizer.state {
		case .began:
			startPos = activeMoon.center
			animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
			animator.addAnimations {
				self.activeMoon.center.y = self.startPos.y + self.moonPathRadius
				self.activeMoon.transform = CGAffineTransform(scaleX: self.firstScale, y: self.firstScale)
				self.activeMoon.currentScale = self.firstScale
			}
			var nextIDX = idx + 1
			var spacing: Double = 42.0
			var newScale: CGFloat = firstScale
			while nextIDX < moonViews.count {
				let nextMoon = moonViews[nextIDX]
					
				animator.addAnimations {
					UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
						var startAngle: Double = 450.0 //nextMoon.currentAngle
						let endAngle: Double = startAngle - spacing
						print(spacing, startAngle, endAngle)
						let incAngle: Double = (startAngle - endAngle) / Double(self.moonPathRadius)
						//let newScale: CGFloat = nextMoon.currentScale - 0.04
						for i in 1...Int(self.moonPathRadius) {
							startAngle -= incAngle
							let p = CGPoint.pointOnCircle(center: self.planetCenter, radius: self.moonPathRadius, angle: CGFloat(startAngle.degreesToRadians))
							let duration = 1.0 / Double(self.moonPathRadius)
							let startTime = duration * Double(i)
							UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: duration) {
								nextMoon.center = p
								
							}
						}
						nextMoon.transform = CGAffineTransform(scaleX: newScale, y: newScale)
						nextMoon.currentAngle = endAngle
						nextMoon.currentScale = newScale
					})
					spacing *= 0.925
				}

				nextIDX += 1
			}
			animator.addCompletion({ b in
				var nextIDX = idx + 1
				while nextIDX < self.moonViews.count {
					let nextMoon = self.moonViews[nextIDX]
					if b == .end {
						nextMoon.previousAngle = nextMoon.currentAngle
						nextMoon.previousScale = nextMoon.currentScale
					} else {
						nextMoon.currentAngle = nextMoon.previousAngle
						nextMoon.currentScale = nextMoon.previousScale
					}
					nextIDX += 1
				}
				if b == .end {
					self.activeMoon = self.moonViews[idx - 1]
				}
			})
			animator.startAnimation()
			animator.pauseAnimation()
		case .changed:
			animator.fractionComplete = recognizer.translation(in: self.view).y / moonPathRadius
		case .ended:
			if animator.fractionComplete < 0.5 {
				animator.isReversed = true
			}
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
		default:
			()
		}
	}

}

class RoundView: UIView {
	
	var currentAngle: Double = 450.0
	var currentScale: CGFloat = 1.0
	
	var previousAngle: Double = 450.0
	var previousScale: CGFloat = 1.0
	
	let label = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() -> Void {
		backgroundColor = .systemBlue
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .white
		label.font = .systemFont(ofSize: 56.0)
		addSubview(label)
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: centerXAnchor),
			label.centerYAnchor.constraint(equalTo: centerYAnchor),
		])
		layer.borderWidth = 1
		layer.borderColor = UIColor.blue.cgColor
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.width * 0.5
	}
	
}


class selfRoundView: UIView {
	
	let label = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() -> Void {
		backgroundColor = .systemBlue
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .white
		addSubview(label)
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: centerXAnchor),
			label.centerYAnchor.constraint(equalTo: centerYAnchor),
		])
		layer.borderWidth = 1
		layer.borderColor = UIColor.blue.cgColor
		
		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
		addGestureRecognizer(panRecognizer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.width * 0.5
	}
	
	var startPos: CGPoint = .zero
	var maxDistance: CGFloat = 0
	var minScale: CGFloat = 0.3
	
	@objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
		let translation  = recognizer.translation(in: self.superview)
		switch recognizer.state {
		case .began:
			startPos = self.center
			maxDistance = bounds.height
			
		case .changed:
			let newY = max(0.0, min(maxDistance, translation.y))
			self.center.y = startPos.y + newY
			let sc = 1.0 - minScale * newY / maxDistance
			self.transform = CGAffineTransform(scaleX: sc, y: sc)
			
		default:
			()
		}
	}
	
}

extension CGPoint {
	
	static func pointOnCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
		let x = center.x + radius * cos(angle)
		let y = center.y + radius * sin(angle)
		return CGPoint(x: x, y: y)
	}
	
}

extension BinaryInteger {
	var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
	var degreesToRadians: Self { self * .pi / 180 }
	var radiansToDegrees: Self { self * 180 / .pi }
}
extension Double {
	var degreesToRadians: Self { self * .pi / 180 }
	var radiansToDegrees: Self { self * 180 / .pi }
}
