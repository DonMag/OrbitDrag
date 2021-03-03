//
//  ViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class ViewController: UIViewController {

	let planetDiameter: CGFloat = 150
	var currentPercent: CGFloat = 0.0
	
	var moonViews: [RoundView] = []
	var activeMoon: RoundView!

	var animator = UIViewPropertyAnimator()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		for i in 1...8 {
			let v = RoundView()
			v.label.text = "\(i)"
			view.addSubview(v)
			moonViews.append(v)
		}
		
		idx = moonViews.count - 1
		activeMoon = moonViews[idx]
		
		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
		view.addGestureRecognizer(panRecognizer)

	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if moonViews.first?.frame.origin.x == 0 {
			moonViews.forEach { moon in
				moon.frame = CGRect(origin: .zero, size: CGSize(width: planetDiameter, height: planetDiameter))
				moon.center = view.center
			}
		}
	}
	
	var idx: Int = 0
	var startPos: CGPoint = .zero
	var maxDistance: CGFloat = 0
	var minScale: CGFloat = 0.7
	
	@objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
		let translation  = recognizer.translation(in: self.view)
		switch recognizer.state {
		case .began:
			startPos = activeMoon.center
			maxDistance = activeMoon.frame.height
			
		case .changed:
			let newY = max(0.0, min(maxDistance, translation.y))
			activeMoon.center.y = startPos.y + newY
			let sc = 1.0 - ((1.0 - minScale) * newY / maxDistance)
			activeMoon.transform = CGAffineTransform(scaleX: sc, y: sc)
			
		case .ended:
			let newY = maxDistance
			let sc = minScale
			UIView.animate(withDuration: 0.3, animations: {
				self.activeMoon.center.y = self.startPos.y + newY
				self.activeMoon.transform = CGAffineTransform(scaleX: sc, y: sc)
			}, completion: { b in
				self.idx -= 1
				self.activeMoon = self.moonViews[self.idx]
			})

		default:
			()
		}
	}

}

class RoundView: UIView {
	
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

