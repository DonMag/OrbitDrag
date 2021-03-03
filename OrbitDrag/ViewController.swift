//
//  ViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class ViewController: UIViewController {

	let numDiscs: Int = 12
	
	let initialDiscRadius: CGFloat = 80
	var initialDiscCenter: CGPoint = .zero
	lazy var discPathRadius: CGFloat = initialDiscRadius * 1.75
	let firstScale: CGFloat = 0.60
	
	var discViews: [DiscView] = []
	var activeDisc: DiscView!

	var animator = UIViewPropertyAnimator()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		for i in 1...numDiscs {
			let v = DiscView()
			v.label.text = "\(i)"
			view.addSubview(v)
			discViews.append(v)
		}

		guard let v = discViews.last else {
			fatalError("We didn't add any Discs!")
		}
		activeDisc = v
		
		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
		view.addGestureRecognizer(panRecognizer)

	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if discViews.first?.frame.origin.x == 0 {
			initialDiscCenter = view.center
			discViews.forEach { disc in
				disc.frame = CGRect(origin: .zero, size: CGSize(width: initialDiscRadius * 2.0, height: initialDiscRadius * 2.0))
				disc.center = initialDiscCenter
			}
		}
	}
	
	@objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
		guard let idx = discViews.firstIndex(of: activeDisc),
			  idx > 0
		else {
			return
		}
		switch recognizer.state {
		case .began:
			let startPos = activeDisc.center
			animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
			animator.addAnimations {
				self.activeDisc.center.y = startPos.y + self.discPathRadius
				self.activeDisc.transform = CGAffineTransform(scaleX: self.firstScale, y: self.firstScale)
			}
			var nextIDX = idx + 1
			var spacing: Double = 42.0
			var newScale: CGFloat = firstScale
			var startAngle: Double = 450.0 //nextDisc.currentAngle
			while nextIDX < discViews.count {
				let nextDisc = discViews[nextIDX]
					
				animator.addAnimations {
					UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
						let endAngle: Double = startAngle - spacing
						let incAngle: Double = (startAngle - endAngle) / Double(self.discPathRadius)
						newScale -= 0.04
						for i in 1...Int(self.discPathRadius) {
							startAngle -= incAngle
							let p = CGPoint.pointOnCircle(center: self.initialDiscCenter, radius: self.discPathRadius, angle: CGFloat(startAngle.degreesToRadians))
							let duration = 1.0 / Double(self.discPathRadius)
							let startTime = duration * Double(i)
							UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: duration) {
								nextDisc.center = p
								
							}
						}
						nextDisc.transform = CGAffineTransform(scaleX: newScale, y: newScale)
					})
					spacing *= 0.925
				}

				nextIDX += 1
			}
			animator.addCompletion({ b in
				if b == .end {
					self.activeDisc = self.discViews[idx - 1]
				}
			})
			animator.startAnimation()
			animator.pauseAnimation()
		case .changed:
			animator.fractionComplete = recognizer.translation(in: self.view).y / discPathRadius
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

class DiscView: UIView {
	
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
