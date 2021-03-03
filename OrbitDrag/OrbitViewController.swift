//
//  OrbitViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class OrbitViewController: UIViewController {
	
	let statLabel = UILabel()
	let moonView = RoundView()
	let planetView = RoundView()
	
	let planetDiameter: CGFloat = 150
	let moonMinDiameter: CGFloat = 40
	let moonMaxDiameter: CGFloat = 80
	
	let moonMinAngle: CGFloat = .pi
	
	var moonX: NSLayoutConstraint!
	var moonY: NSLayoutConstraint!
	var moonW: NSLayoutConstraint!
	
	var currentPercent: CGFloat = 0.0
	
	var panStart: CGPoint = .zero
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		planetView.backgroundColor = .blue
		moonView.backgroundColor = .red
		
		[statLabel, planetView, moonView].forEach { v in
			view.addSubview(v)
			v.translatesAutoresizingMaskIntoConstraints = false
		}
		
		// respect safe area
		let g = view.safeAreaLayoutGuide
		
		moonX = moonView.centerXAnchor.constraint(equalTo: planetView.centerXAnchor)
		moonY = moonView.centerYAnchor.constraint(equalTo: planetView.centerYAnchor)
		moonW = moonView.widthAnchor.constraint(equalToConstant: moonMinDiameter)
		
		NSLayoutConstraint.activate([
			
			// constrain stat label at top
			statLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 8.0),
			statLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16.0),
			statLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16.0),
			
			// constrain planetView in center of view
			planetView.centerXAnchor.constraint(equalTo: g.centerXAnchor),
			planetView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
			planetView.widthAnchor.constraint(equalToConstant: planetDiameter),
			planetView.heightAnchor.constraint(equalTo: planetView.widthAnchor),
			
			// activate moon X, Y, W constraints
			moonX, moonY, moonW,
			// moon height equal to width (1:1 ratio)
			moonView.heightAnchor.constraint(equalTo: moonView.widthAnchor),
			
		])
		
		// add Pan gesture
		let p = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
		view.addGestureRecognizer(p)
		
		updateStatLabel()
	}
	
	
	func updateStatLabel() -> Void {
		statLabel.text = String(format: "Current Percentage: %0.2f", currentPercent)
	}
	
	@objc private func handlePan(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .changed:
			let tr = recognizer.translation(in: self.view)
			// vertical pan of 3-points == 1%
			let pct = tr.y / 3.0
			currentPercent += pct
			recognizer.setTranslation(.zero, in: self.view)
			// set currentPercent min: 0.0 max: 100.0
			currentPercent = max(0.0, min(100.0, currentPercent))
			
			let newMoonDiameter: CGFloat = moonMinDiameter + ((moonMaxDiameter - moonMinDiameter) * currentPercent / 100.0)
			let orbitRadius: CGFloat = planetDiameter * 0.5 + newMoonDiameter * 0.6
			let angle = .pi + (.pi * 1.5 * currentPercent / 100.0)
			let pt = CGPoint.pointOnCircle(center: planetView.center, radius: orbitRadius, angle: CGFloat(angle))
			// move moonView to pt
			moonX.constant =  pt.x - planetView.center.x
			moonY.constant = pt.y - planetView.center.y
			// scale moonView by percentage between min/max diameter
			moonW.constant = newMoonDiameter
			self.updateStatLabel()
		default:
			()
		}
	}
	
}
