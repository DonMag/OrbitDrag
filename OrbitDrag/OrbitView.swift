//
//  OrbitView.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class OrbitView: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() -> Void {
		// add the pan gesture
		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan(_:)))
		addGestureRecognizer(panRecognizer)
		
		// default of 7 equal scores
		//	so there is something to see if scores are not set
		scores = [1, 1, 1, 1, 1, 1, 1]
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		// only initialize discViews if bounds has changed
		//	(or when forced by numDiscs being set)
		if bounds.size != thisSize {
			thisSize = bounds.size

			// use a 1:1 ratio frame in the center
			let thisWidth = min(bounds.width, bounds.height)
			//  using "center disc" width of 30% of the view
			//	will allow all discs to fit
			//	so the radius is 0.15
			centerDiscRadius = thisWidth * 0.15
			// radius for "orbit" path
			//	provides a little space between the center disc and the surrounding discs
			orbitPathRadius = centerDiscRadius * 2.15
			// init all discs at "center disc" size, centered in self
			discViews.forEach { disc in
				disc.transform = .identity
				disc.frame = CGRect(origin: .zero, size: CGSize(width: centerDiscRadius * 2.0, height: centerDiscRadius * 2.0))
				disc.center = CGPoint(x: bounds.midX, y: bounds.midY)
			}
			
			// size may have changed (perhaps on device rotation)
			//	if one or more discs has already been pulled down
			//	update and re-scale the "orbiting" discs
			if activeDisc != discViews.last {
				guard let idx = discViews.firstIndex(of: activeDisc)
				else {
					return
				}
				let curDiscs: [DiscView] = Array(discViews[(idx+1)..<discViews.count])
				curDiscs.forEach { v in
					// get point on discPathRadius circle
					let p = CGPoint.pointOnCircle(center: self.discViews[0].center, radius: self.orbitPathRadius, angle: CGFloat(v.currentDegrees.degreesToRadians))
					v.center = p
					let sc: CGFloat = CGFloat(v.scorePct)
					v.transform = CGAffineTransform(scaleX: sc, y: sc)
				}
			}
		}
	}
	
	public var scores: [Double] = [] {
		didSet {
			// clear any existing discs
			discViews.forEach {
				$0.removeFromSuperview()
			}
			discViews.removeAll()
			var tempScores: [Double] = scores
			// make sure we have at least 1 score
			if tempScores.count == 0 {
				tempScores = [1, 1, 1, 1, 1, 1, 1]
			}
			// make sure scores are in descending order
			let sortedScores = scores.sorted { $0 > $1 }
			var i = 1
			// create new discs
			sortedScores.forEach { val in
				let v = DiscView()
				let m = Metric(name: "", value: val)
				v.label.text = m.formattedValue
				v.score = val
				addSubview(v)
				discViews.append(v)
				i += 1
			}
			guard let v = discViews.last else {
				fatalError("We didn't add any Discs!")
			}
			activeDisc = v
			// trigger layout
			thisSize = .zero
			setNeedsLayout()
		}
	}
	
	// used in layoutSubviews
	private var thisSize: CGSize = .zero

	// "center disc" radius, set in layoutSubviews
	private var centerDiscRadius: CGFloat = 0
	
	// radius for "orbit" path, set in layoutSubviews
	private var orbitPathRadius: CGFloat = 0
	
	// distance (in degrees) between discs
	//	consecutive 100% discs will need 60-degrees
	//	calculations are made on each disc, so
	//	use one-half of 60-degrees
	private let baseDistance: Double = 30
	
	// array of "discs"
	private var discViews: [DiscView] = []
	
	// the disc "on top of the stack" that can be dragged
	private var activeDisc: DiscView!
	
	// used to move/scale discs while dragging
	private var animator = UIViewPropertyAnimator()
	
	enum PanDirection {
		case up, down, undetermined
	}
	var panDir: PanDirection = .undetermined
	
	@objc func detectPan(_ recognizer: UIPanGestureRecognizer) {

		var idx: Int = 0
		
		// make sure we have an active disc
		guard let i = discViews.firstIndex(of: activeDisc) else { return }
		
		idx = i

		switch recognizer.state {
		case .began:

			if panDir == .undetermined {
				// make sure the drag starts inside the center disc
				let pt = recognizer.location(in: self)
				var pth = UIBezierPath(ovalIn: activeDisc.frame)
				// are we dragging from center disc?
				if pth.contains(pt) && recognizer.translation(in: self).y > 0 {
					// make sure we're not on the last (bottom) disc
					if idx == 0 {
						return
					}
					panDir = .down
				} else if idx < discViews.count - 1 {
					pth = UIBezierPath(ovalIn: discViews[idx+1].frame)
					// are we dragging from disc at 90-degrees (6 o'clock)?
					if pth.contains(pt) && recognizer.translation(in: self).y < 0 {
						idx += 1
						panDir = .up
					}
				}
			}
			
			if panDir == .undetermined {
				return
			}

			// get array of "current" discs
			//	the disc being dragged +
			//	any discs that have already been dragged out
			//
			let curDiscs: [DiscView] = Array(discViews[idx..<discViews.count])
			
			var curMaxScore = curDiscs[0].score
			if panDir == .down {
				curMaxScore = discViews[idx - 1].score
			}
			
			// we're starting at 90-degrees (6 o'clock)
			var d: Double = 90
			
			// disc being dragged
			curDiscs[0].scorePct = curDiscs[0].score / curMaxScore
			curDiscs[0].nextDegrees = d
			
			// for any discs that have already been dragged out
			for i in 1..<curDiscs.count {
				// set percentage based on current Max score
				curDiscs[i].scorePct = curDiscs[i].score / curMaxScore
				// calculate distance (in degrees) from previous disc
				let dist: Double = (baseDistance * Double(curDiscs[i].scorePct)) + (baseDistance * Double(curDiscs[i-1].scorePct))
				// subtract from previous position (in degrees)
				if panDir == .down {
					d -= dist
					curDiscs[i].nextDegrees = d
				} else {
					curDiscs[i].nextDegrees = d
					d -= dist
				}
			}
			
			// starting position of disc to drag
			let startPosY = discViews[0].center.y
			
			// create new animator
			animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
			
			// we're moving activeDisc only vertically
			//	and scaling down from 1.0 to first scale size
			//	or up to 1.0 from first scale size
			animator.addAnimations {
				curDiscs[0].center.y = startPosY + (self.panDir == .down ? self.orbitPathRadius : 0)
				let sc: CGFloat = CGFloat(curDiscs[0].scorePct)
				curDiscs[0].transform = CGAffineTransform(scaleX: sc, y: sc)
			}
			
			// starting point
			var startDegrees: Double = 0
			// ending point
			var endDegrees: Double = 0
			
			// we need the same number of keyframes as points for the vertical drag
			let numSteps: CGFloat = orbitPathRadius
			
			// handle discs that have already been dragged off the center
			var nextIDX = 1
			
			while nextIDX < curDiscs.count {
				let nextDisc = curDiscs[nextIDX]
				
				// scale based on percent
				animator.addAnimations {
					let sc: CGFloat = CGFloat(nextDisc.scorePct)
					nextDisc.transform = CGAffineTransform(scaleX: sc, y: sc)
				}
				
				// to move the discs around the center disc, we
				//	calculate the same number of points on the orbit path
				//	as the number of points the "dragging" disc needs to move
				//	and use Key Frame animation
				animator.addAnimations {
					UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
						startDegrees = nextDisc.currentDegrees
						endDegrees = nextDisc.nextDegrees
						let stepDegrees: Double = (startDegrees - endDegrees) / Double(numSteps)
						for i in 1...Int(numSteps) {
							// decrement degrees by step value
							startDegrees -= stepDegrees
							// get point on discPathRadius circle
							let p = CGPoint.pointOnCircle(center: self.discViews[0].center, radius: self.orbitPathRadius, angle: CGFloat(startDegrees.degreesToRadians))
							// duration is 1 divided by number of steps
							let duration = 1.0 / Double(numSteps)
							// start time for this frame is duration * this step
							let startTime = duration * Double(i)
							// add the keyframe
							UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: duration) {
								nextDisc.center = p
							}
						}
					})
				}
				
				nextIDX += 1
			}
			
			// add a completion block
			animator.addCompletion({ b in
				// if we animated forward to the end
				if b == .end {
					// set new active disc
					self.activeDisc = (self.panDir == .down) ? self.discViews[idx - 1] : self.discViews[idx]
					curDiscs.forEach { v in
						v.currentDegrees = v.nextDegrees
					}
				}
				self.panDir = .undetermined
			})
			
			// start and immediately pause the animation
			animator.startAnimation()
			animator.pauseAnimation()
			
		case .changed:
			// pan gesture changed (touch moved), so
			//	update the animator progress
			var ty = recognizer.translation(in: self).y
			if panDir == .up {
				ty = abs(ty)
			}
			animator.fractionComplete = ty / orbitPathRadius
			
		default:
			// if we dragged down less than 1/3rd of the way (or dragged down and back up)
			if animator.fractionComplete < 0.333 {
				// reverse the animation
				animator.isReversed = true
			}
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			
		}
		
	}
	
}

