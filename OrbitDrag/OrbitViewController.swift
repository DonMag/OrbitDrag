//
//  OrbitViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class OrbitViewController: UIViewController {

	let numDiscs: Int = 12
	
	let firstScale: CGFloat = 0.60
	let initialDiscRadius: CGFloat = 80
	
	lazy var discPathRadius: CGFloat = initialDiscRadius * 1.75
	
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
		if discViews.first?.frame.size.width == 0 {
			discViews.forEach { disc in
				disc.frame = CGRect(origin: .zero, size: CGSize(width: initialDiscRadius * 2.0, height: initialDiscRadius * 2.0))
				disc.center = view.center
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
			var startAngle: Double = 450.0
			while nextIDX < discViews.count {
				let nextDisc = discViews[nextIDX]
				animator.addAnimations {
					UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
						let endAngle: Double = startAngle - spacing
						let incAngle: Double = (startAngle - endAngle) / Double(self.discPathRadius)
						newScale -= 0.04
						for i in 1...Int(self.discPathRadius) {
							startAngle -= incAngle
							let p = CGPoint.pointOnCircle(center: self.discViews[0].center, radius: self.discPathRadius, angle: CGFloat(startAngle.degreesToRadians))
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
