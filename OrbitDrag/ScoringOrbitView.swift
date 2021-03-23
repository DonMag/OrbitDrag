//
//  ScoringOrbitView.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/5/21.
//

import UIKit


class ScoringOrbitView: UIView {
	
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
		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
		addGestureRecognizer(panRecognizer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		// only initialize discViews if bounds has changed
		//	(or when forced by numDiscs being set)
		if bounds.width != thisWidth {
			thisWidth = bounds.width
			// assuming we're a 1:1 ratio view
			//  using "center disc" width of 30% of the view
			//	will allow all discs to fit
			//	so the radius is 0.15
			centerDiscRadius = bounds.width * 0.15
			// radius for "orbit" path
			//	provides a little space between the center disc and the surrounding discs
			orbitPathRadius = centerDiscRadius * 2.15
			// init all discs at "center disc" size, centered in self
			discViews.forEach { disc in
				disc.frame = CGRect(origin: .zero, size: CGSize(width: centerDiscRadius * 2.0, height: centerDiscRadius * 2.0))
				disc.center = CGPoint(x: bounds.midX, y: bounds.midY)
			}
		}
	}
	
	private var maxScore: CGFloat = 0
	
	public var scores: [CGFloat] = [] {
		didSet {
			// clear any existing discs
			subviews.forEach {
				$0.removeFromSuperview()
			}
			discViews.removeAll()
			// get the max score
			if let mx = scores.max() {
				maxScore = mx
			}
			var i = 1
			// create new discs
			scores.forEach { val in
				let v = ScoreDiscView()
				v.label.text = "\(val)\n\(i)"
				//v.label.text = "\(i)"
				v.score = val
				v.scorePct = val / maxScore
				addSubview(v)
				discViews.append(v)
				i += 1
			}
			guard let v = discViews.last else {
				fatalError("We didn't add any Discs!")
			}
			activeDisc = v
			// trigger layout
			thisWidth = 0
			setNeedsLayout()
		}
	}
	
	// used in layoutSubviews
	private var thisWidth: CGFloat = 0
	
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
	private var discViews: [ScoreDiscView] = []
	
	// the disc "on top of the stack" that can be dragged
	private var activeDisc: ScoreDiscView!

	// used to move/scale discs while dragging
	private var animator = UIViewPropertyAnimator()
	
	// we only want to drag if the touch starts inside the center disc
	private var isDragging: Bool = false
	
	@objc func detectPan(_ recognizer: UIPanGestureRecognizer) {

		// make sure we're not on the last (bottom) disc
		guard let idx = discViews.firstIndex(of: activeDisc),
			  idx > 0
		else {
			return
		}
		
		switch recognizer.state {
		case .began:
			// make sure the drag starts inside the center disc
			let pth = UIBezierPath(ovalIn: discViews[0].frame)
			let pt = recognizer.location(in: self)
			if !pth.contains(pt) {
				return
			}
			
			// get array of "current" discs, this will be:
			//	the disc "remaining" in the center +
			//	the disc being dragged +
			//	any discs that have already been dragged out
			let curDiscs: [ScoreDiscView] = Array(discViews[(idx - 1)..<discViews.count])
			
			// get the score of the "remaining" center disc as the
			//	current MAX score
			let curMaxScore = curDiscs[0].score

			// we're starting at 90-degrees (6 o'clock)
			var d: Double = 90
			
			// remaining center disc is 100%
			curDiscs[0].scorePct = 1
			
			// disc being dragged down
			curDiscs[1].scorePct = curDiscs[1].score / curMaxScore
			curDiscs[1].nextDegrees = d
			
			// for any discs that have already been dragged out
			for i in 2..<curDiscs.count {
				// set percentage based on current Max score
				curDiscs[i].scorePct = curDiscs[i].score / curMaxScore
				// calculate distance (in degrees) from previous disc
				let dist: Double = (baseDistance * Double(curDiscs[i].scorePct)) + (baseDistance * Double(curDiscs[i-1].scorePct))
				// subtract from previous position (in degrees)
				d -= dist
				curDiscs[i].nextDegrees = d
			}
			
			// set dragging flag
			isDragging = true
			
			// starting position of disc to drag
			let startPosY = curDiscs[1].center.y
			
			// create new animator
			animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
			
			// we're moving activeDisc only vertically
			//	and scaling down from 1.0 to first scale size
			animator.addAnimations {
				curDiscs[1].center.y = startPosY + self.orbitPathRadius
				let sc: CGFloat = curDiscs[1].scorePct
				curDiscs[1].transform = CGAffineTransform(scaleX: sc, y: sc)
			}
			
			// starting point
			var startDegrees: Double = 0
			// ending point
			var endDegrees: Double = 0
			
			// we need the same number of keyframes as points for the vertical drag
			let numSteps: CGFloat = orbitPathRadius

			// handle discs that have already been dragged off the center
			var nextIDX = 2

			while nextIDX < curDiscs.count {
				let nextDisc = curDiscs[nextIDX]
				
				// scale based on percent
				animator.addAnimations {
					let sc: CGFloat = nextDisc.scorePct
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
					self.activeDisc = curDiscs[0]	// self.discViews[idx - 1]
					// hide any discs with scale smaller than 0.01 (1%)
					//self.discViews.forEach { v in
					curDiscs.forEach { v in
						v.isHidden = v.scorePct < 0.01
						v.currentDegrees = v.nextDegrees
					}
				}
			})

			// start and immediately pause the animation
			animator.startAnimation()
			animator.pauseAnimation()
			
		case .changed:
			// pan gesture changed (touch moved), so
			//	update the animator progress
			animator.fractionComplete = recognizer.translation(in: self).y / orbitPathRadius
			
		case .ended:
			// if we dragged down less than 1/3rd of the way (or dragged down and back up)
			if animator.fractionComplete < 0.333 {
				// reverse the animation
				animator.isReversed = true
			}
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			// we're no longer dragging
			isDragging = false

		default:
			()
		}

/*
		switch recognizer.state {
		case .began:
			// make sure the drag starts inside the center disc
			let pth = UIBezierPath(ovalIn: discViews[0].frame)
			let pt = recognizer.location(in: self)
			if !pth.contains(pt) {
				return
			}
			
			let curDiscs: [ScoreDiscView] = Array(discViews[(idx - 1)..<discViews.count])
			let curScores: [CGFloat] = Array(scores[(idx - 1)..<scores.count])
			guard let curMax = curScores.max(),
				  let curMin = curScores.min()
			else {
				return
			}
			let curRange = curMax - curMin


			isDragging = true
			
			// starting position of disc to drag
			let startPosY = activeDisc.center.y
			
			// create new animator
			animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
			
			// we're moving activeDisc only vertically
			//	and scaling down from 1.0 to first scale size
			animator.addAnimations {
				self.activeDisc.center.y = startPosY + self.discPathRadius
				let sc: CGFloat = self.minScale + (self.activeDisc.scorePct * self.scaleRange)
				self.activeDisc.transform = CGAffineTransform(scaleX: sc, y: sc)
			}
			
			// handle discs that have already been dragged off the center
			var nextIDX = idx + 1
			// scale for next disc
			//	this will reduce for each successive disc
			var newScale: CGFloat = maxScale
			// degrees to the next disc's final position
			//	this will reduce for each successive disc
			let baseSpacing: Double = 60.0
			var spacingDegrees: Double = 42.0
			// starting point: 90 degrees
			var startDegrees: Double = 90.0
			// ending point
			var endDegrees: Double = 0
			// we need the same number of keyframes as points for the vertical drag
			let numSteps: CGFloat = discPathRadius
			if nextIDX < discViews.count {
				var nextDisc = self.discViews[nextIDX]
				// get the next disc
				animator.addAnimations {
					let prevDisc = self.discViews[nextIDX - 1]
					nextDisc = self.discViews[nextIDX]
					let d1: Double = Double(prevDisc.transform.a) * baseSpacing / 2.0
					let d2: Double = Double(nextDisc.transform.a) * baseSpacing / 2.0
					spacingDegrees = d1 + d2 // Double((prevDisc.scorePct * 21.0) + (nextDisc.scorePct * 21.0))
					print("spd:", spacingDegrees)
					while nextIDX < self.discViews.count {
						nextDisc = self.discViews[nextIDX]
						UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
							startDegrees = nextDisc.currentDegrees
							endDegrees = startDegrees - spacingDegrees
							print(nextDisc.label.text, nextDisc.currentDegrees, nextDisc.nextDegrees)
							nextDisc.nextDegrees = endDegrees
							print("st:", startDegrees, "e:", endDegrees)
							let stepDegrees: Double = (startDegrees - endDegrees) / Double(numSteps)
							for i in 1...Int(numSteps) {
								// decrement degrees by step value
								startDegrees -= stepDegrees
								// get point on discPathRadius circle
								let p = CGPoint.pointOnCircle(center: self.discViews[0].center, radius: self.discPathRadius, angle: CGFloat(startDegrees.degreesToRadians))
								// duration is 1 divided by number of steps
								let duration = 1.0 / Double(numSteps)
								// start time for this frame is duration * this step
								let startTime = duration * Double(i)
								// add the keyframe
								UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: duration) {
									nextDisc.center = p
								}
							}
							//startDegrees = endDegrees
							// as we move around the circle, the scales will decrease, so
							//	decrease the distance for each successive disc
							//spacingDegrees *= 0.925
						})
						nextIDX += 1
					}
				}
			}
			// add completion block
			animator.addCompletion({ b in
				// if we animated forward to the end
				if b == .end {
					// set new active disc
					self.activeDisc = self.discViews[idx - 1]
					// hide any discs with scale smaller than 0.1 (10%)
					self.discViews.forEach { v in
						v.isHidden = v.transform.a < 0.1
						//print(v.label.text, v.currentDegrees, v.nextDegrees)
						v.currentDegrees = v.nextDegrees
					}
				}
			})
			// start and immediately pause the animation
			animator.startAnimation()
			animator.pauseAnimation()
		case .changed:
			// pan gesture changed (touch moved), so
			//	update the animator progress
			animator.fractionComplete = recognizer.translation(in: self).y / discPathRadius
		case .ended:
			// if we dragged down less than 1/3rd of the way (or dragged down and back up)
			if animator.fractionComplete < 0.333 {
				// reverse the animation
				animator.isReversed = true
			}
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			// we're no longer dragging
			isDragging = false
		default:
			()
		}
		*/
	}
	
}




class zzzScoringOrbitView: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() -> Void {
		// default number of discs
		//numDiscs = 12
		// add the pan gesture
		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
		addGestureRecognizer(panRecognizer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		// only initialize discViews if bounds has changed
		//	(or when forced by numDiscs being set)
		if bounds.width != thisWidth {
			thisWidth = bounds.width
			// assuming we're a 1:1 ratio view
			//  using "center disc" radius of width * 0.2 will allow all discs to fit
			centerDiscRadius = bounds.width * 0.1
			// radius for "orbit" path
			discPathRadius = centerDiscRadius * 2.25
			// init all discs at "center disc" size, centered in self
			discViews.forEach { disc in
				disc.frame = CGRect(origin: .zero, size: CGSize(width: centerDiscRadius * 2.0, height: centerDiscRadius * 2.0))
				disc.center = CGPoint(x: bounds.midX, y: bounds.midY)
			}
		}
	}
	
	private var maxScore: CGFloat = 0
	
	public var scores: [CGFloat] = [] {
		didSet {
			// clear any existing discs
			subviews.forEach {
				$0.removeFromSuperview()
			}
			discViews.removeAll()
			// get the max score
			if let mx = scores.max() {
				maxScore = mx
			}
			var i = 1
			// create new discs
			scores.forEach { val in
				let v = ScoreDiscView()
				v.label.text = "\(val)\n\(i)"
				v.label.text = "\(i)"
				v.score = val
				v.scorePct = val / maxScore
				addSubview(v)
				discViews.append(v)
				i += 1
			}
			guard let v = discViews.last else {
				fatalError("We didn't add any Discs!")
			}
			activeDisc = v
			// trigger layout
			thisWidth = 0
			setNeedsLayout()
		}
	}
	
	private var spacingDegrees: Double = 42.0
	
	// used in layoutSubviews
	private var thisWidth: CGFloat = 0
	
	// scale for disc at 6 o'clock
	private let maxScale: CGFloat = 1.0
	private let minScale: CGFloat = 0.0
	private let scaleRange: CGFloat = 1.0
	
	// "center disc" radius, set in layoutSubviews
	private var centerDiscRadius: CGFloat = 0
	
	// radius for "orbit" path, set in layoutSubviews
	private var discPathRadius: CGFloat = 0
	
	// array of "discs"
	private var discViews: [ScoreDiscView] = []
	
	// the disc "on top of the stack" that can be dragged
	private var activeDisc: ScoreDiscView!
	
	private var animator = UIViewPropertyAnimator()
	
	// we only want to drag if the touch starts inside the center disc
	private var isDragging: Bool = false
	
	@objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
		// make sure we're not on the last disc
		guard let idx = discViews.firstIndex(of: activeDisc),
			  idx > 0
		else {
			return
		}
		switch recognizer.state {
		case .began:
			// make sure the drag starts inside the center disc
			let pth = UIBezierPath(ovalIn: discViews[0].frame)
			let pt = recognizer.location(in: self)
			if !pth.contains(pt) {
				return
			}
			isDragging = true
			
			// starting position of disc to drag
			let startPosY = activeDisc.center.y
			
			// create new animator
			animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
			
			// we're moving activeDisc only vertically
			//	and scaling down from 1.0 to first scale size
			animator.addAnimations {
				self.activeDisc.center.y = startPosY + self.discPathRadius
				let sc: CGFloat = self.minScale + (self.activeDisc.scorePct * self.scaleRange)
				self.activeDisc.transform = CGAffineTransform(scaleX: sc, y: sc)
			}
			
			// handle discs that have already been dragged off the center
			var nextIDX = idx + 1
			// scale for next disc
			//	this will reduce for each successive disc
			var newScale: CGFloat = maxScale
			// degrees to the next disc's final position
			//	this will reduce for each successive disc
			let baseSpacing: Double = 60.0
			var spacingDegrees: Double = 42.0
			// starting point: 90 degrees
			var startDegrees: Double = 90.0
			// ending point
			var endDegrees: Double = 0
			// we need the same number of keyframes as points for the vertical drag
			let numSteps: CGFloat = discPathRadius
			if nextIDX < discViews.count {
				var nextDisc = self.discViews[nextIDX]
				// get the next disc
				animator.addAnimations {
					let prevDisc = self.discViews[nextIDX - 1]
					nextDisc = self.discViews[nextIDX]
					let d1: Double = Double(prevDisc.transform.a) * baseSpacing / 2.0
					let d2: Double = Double(nextDisc.transform.a) * baseSpacing / 2.0
					spacingDegrees = d1 + d2 // Double((prevDisc.scorePct * 21.0) + (nextDisc.scorePct * 21.0))
					print("spd:", spacingDegrees)
					while nextIDX < self.discViews.count {
						nextDisc = self.discViews[nextIDX]
						UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
							startDegrees = nextDisc.currentDegrees
							endDegrees = startDegrees - spacingDegrees
							print(nextDisc.label.text, nextDisc.currentDegrees, nextDisc.nextDegrees)
							nextDisc.nextDegrees = endDegrees
							print("st:", startDegrees, "e:", endDegrees)
							let stepDegrees: Double = (startDegrees - endDegrees) / Double(numSteps)
							for i in 1...Int(numSteps) {
								// decrement degrees by step value
								startDegrees -= stepDegrees
								// get point on discPathRadius circle
								let p = CGPoint.pointOnCircle(center: self.discViews[0].center, radius: self.discPathRadius, angle: CGFloat(startDegrees.degreesToRadians))
								// duration is 1 divided by number of steps
								let duration = 1.0 / Double(numSteps)
								// start time for this frame is duration * this step
								let startTime = duration * Double(i)
								// add the keyframe
								UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: duration) {
									nextDisc.center = p
								}
							}
							//startDegrees = endDegrees
							// as we move around the circle, the scales will decrease, so
							//	decrease the distance for each successive disc
							//spacingDegrees *= 0.925
						})
						nextIDX += 1
					}
				}
			}
			// add completion block
			animator.addCompletion({ b in
				// if we animated forward to the end
				if b == .end {
					// set new active disc
					self.activeDisc = self.discViews[idx - 1]
					// hide any discs with scale smaller than 0.1 (10%)
					self.discViews.forEach { v in
						v.isHidden = v.transform.a < 0.1
						//print(v.label.text, v.currentDegrees, v.nextDegrees)
						v.currentDegrees = v.nextDegrees
					}
				}
			})
			// start and immediately pause the animation
			animator.startAnimation()
			animator.pauseAnimation()
		case .changed:
			// pan gesture changed (touch moved), so
			//	update the animator progress
			animator.fractionComplete = recognizer.translation(in: self).y / discPathRadius
		case .ended:
			// if we dragged down less than 1/3rd of the way (or dragged down and back up)
			if animator.fractionComplete < 0.333 {
				// reverse the animation
				animator.isReversed = true
			}
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			// we're no longer dragging
			isDragging = false
		default:
			()
		}
	}
	
}


/*
class ScoringOrbitView: UIView {

override init(frame: CGRect) {
super.init(frame: frame)
commonInit()
}
required init?(coder: NSCoder) {
super.init(coder: coder)
commonInit()
}
func commonInit() -> Void {
// default number of discs
//numDiscs = 12
// add the pan gesture
let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
addGestureRecognizer(panRecognizer)
}

override func layoutSubviews() {
super.layoutSubviews()
// only initialize discViews if bounds has changed
//	(or when forced by numDiscs being set)
if bounds.width != thisWidth {
thisWidth = bounds.width
// assuming we're a 1:1 ratio view
//  using "center disc" radius of width * 0.2 will allow all discs to fit
centerDiscRadius = bounds.width * 0.1
// radius for "orbit" path
discPathRadius = centerDiscRadius * 2.25
// init all discs at "center disc" size, centered in self
discViews.forEach { disc in
disc.frame = CGRect(origin: .zero, size: CGSize(width: centerDiscRadius * 2.0, height: centerDiscRadius * 2.0))
disc.center = CGPoint(x: bounds.midX, y: bounds.midY)
}
}
}

private var maxScore: CGFloat = 0

public var scores: [CGFloat] = [] {
didSet {
// clear any existing discs
subviews.forEach {
$0.removeFromSuperview()
}
discViews.removeAll()
// get the max score
if let mx = scores.max() {
maxScore = mx
}
var i = 1
// create new discs
scores.forEach { val in
let v = ScoreDiscView()
v.label.text = "\(val)\n\(i)"
//v.label.text = "\(i)"
v.score = val
v.scorePct = val / maxScore
addSubview(v)
discViews.append(v)
i += 1
}
guard let v = discViews.last else {
fatalError("We didn't add any Discs!")
}
activeDisc = v
// trigger layout
thisWidth = 0
setNeedsLayout()
}
}

private var spacingDegrees: Double = 42.0

// used in layoutSubviews
private var thisWidth: CGFloat = 0

// scale for disc at 6 o'clock
private let maxScale: CGFloat = 1.0
private let minScale: CGFloat = 0.0
private let scaleRange: CGFloat = 1.0

// "center disc" radius, set in layoutSubviews
private var centerDiscRadius: CGFloat = 0

// radius for "orbit" path, set in layoutSubviews
private var discPathRadius: CGFloat = 0

// array of "discs"
private var discViews: [ScoreDiscView] = []

// the disc "on top of the stack" that can be dragged
private var activeDisc: ScoreDiscView!

private var animator = UIViewPropertyAnimator()

// we only want to drag if the touch starts inside the center disc
private var isDragging: Bool = false

@objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
// make sure we're not on the last disc
guard let idx = discViews.firstIndex(of: activeDisc),
idx > 0
else {
return
}

switch recognizer.state {
case .began:
// make sure the drag starts inside the center disc
let pth = UIBezierPath(ovalIn: discViews[0].frame)
let pt = recognizer.location(in: self)
if !pth.contains(pt) {
return
}

let curDiscs: [ScoreDiscView] = Array(discViews[(idx - 1)..<discViews.count])
let curScores: [CGFloat] = Array(scores[(idx - 1)..<scores.count])
guard let curMax = curScores.max(),
let curMin = curScores.min()
else {
return
}
let curRange = curMax - curMin
print(curMax)

var curDegrees: Double = 90

let baseSpacing: Double = 30.0

for i in 0..<curScores.count {
curDiscs[i].scorePct = curDiscs[i].score / curMax
if i == 0 {
// first disc stays in center
} else if i == 1 {
// "drag" disc goes straight down
curDiscs[i].currentDegrees = 90
curDiscs[i].nextDegrees = 90
} else {
let prevDisc = curDiscs[i - 1]
let thisDisc = curDiscs[i]
let prevRad = centerDiscRadius * prevDisc.scorePct
let thisRad = centerDiscRadius * thisDisc.scorePct
let dist: Double = (baseSpacing * Double(prevDisc.scorePct)) + (baseSpacing * Double(thisDisc.scorePct))
curDegrees -= dist
thisDisc.nextDegrees = curDegrees
}
}

isDragging = true

// starting position of disc to drag
let startPosY = activeDisc.center.y

// create new animator
animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)

// we're moving activeDisc only vertically
//	and scaling down from 1.0 to first scale size
animator.addAnimations {
self.activeDisc.center.y = startPosY + self.discPathRadius
let sc: CGFloat = self.minScale + (self.activeDisc.scorePct * self.scaleRange)
self.activeDisc.transform = CGAffineTransform(scaleX: sc, y: sc)
}
// handle discs that have already been dragged off the center
var nextIDX = 1

// we need the same number of keyframes as points for the vertical drag
let numSteps: CGFloat = discPathRadius

while nextIDX < curDiscs.count {
animator.addAnimations {
let nextDisc = curDiscs[nextIDX]

}

// scale for next disc
//	this will reduce for each successive disc
var newScale: CGFloat = maxScale
// degrees to the next disc's final position
//	this will reduce for each successive disc
//			let baseSpacing: Double = 60.0
var spacingDegrees: Double = 42.0
// starting point: 90 degrees
var startDegrees: Double = 90.0
// ending point
var endDegrees: Double = 0
if nextIDX < discViews.count {
var nextDisc = self.discViews[nextIDX]
// get the next disc
//				animator.addAnimations {
//					let sc: CGFloat = self.minScale + (nextDisc.scorePct * self.scaleRange)
//					print(nextDisc.label.text, nextDisc.scorePct)
//					nextDisc.transform = CGAffineTransform(scaleX: sc, y: sc)
//				}
animator.addAnimations {
let prevDisc = self.discViews[nextIDX - 1]
nextDisc = self.discViews[nextIDX]

//					let sc: CGFloat = self.minScale + (nextDisc.scorePct * self.scaleRange)
//					print(nextDisc.label.text, nextDisc.scorePct)
//					nextDisc.transform = CGAffineTransform(scaleX: sc, y: sc)

//					let d1: Double = Double(prevDisc.transform.a) * baseSpacing / 2.0
//					let d2: Double = Double(nextDisc.transform.a) * baseSpacing / 2.0
//					spacingDegrees = d1 + d2 // Double((prevDisc.scorePct * 21.0) + (nextDisc.scorePct * 21.0))
//					print("spd:", spacingDegrees)
while nextIDX < self.discViews.count {
nextDisc = self.discViews[nextIDX]
let sc: CGFloat = self.minScale + (nextDisc.scorePct * self.scaleRange)
print(nextDisc.label.text, nextDisc.scorePct)
nextDisc.transform = CGAffineTransform(scaleX: sc, y: sc)
let d1: Double = Double(prevDisc.transform.a) * baseSpacing / 2.0
let d2: Double = Double(nextDisc.transform.a) * baseSpacing / 2.0
spacingDegrees = d1 + d2 // Double((prevDisc.scorePct * 21.0) + (nextDisc.scorePct * 21.0))
UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
startDegrees = nextDisc.currentDegrees
endDegrees = startDegrees - spacingDegrees
//print(nextDisc.label.text, nextDisc.currentDegrees, nextDisc.nextDegrees)
nextDisc.nextDegrees = endDegrees
//print("st:", startDegrees, "e:", endDegrees)
let stepDegrees: Double = (startDegrees - endDegrees) / Double(numSteps)
for i in 1...Int(numSteps) {
// decrement degrees by step value
startDegrees -= stepDegrees
// get point on discPathRadius circle
let p = CGPoint.pointOnCircle(center: self.discViews[0].center, radius: self.discPathRadius, angle: CGFloat(startDegrees.degreesToRadians))
// duration is 1 divided by number of steps
let duration = 1.0 / Double(numSteps)
// start time for this frame is duration * this step
let startTime = duration * Double(i)
// add the keyframe
UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: duration) {
nextDisc.center = p
}
}
//startDegrees = endDegrees
// as we move around the circle, the scales will decrease, so
//	decrease the distance for each successive disc
//spacingDegrees *= 0.925
})
nextIDX += 1
}
}
}
// add completion block
animator.addCompletion({ b in
// if we animated forward to the end
if b == .end {
// set new active disc
self.activeDisc = self.discViews[idx - 1]
// hide any discs with scale smaller than 0.1 (10%)
self.discViews.forEach { v in
v.isHidden = v.transform.a < 0.1
//print(v.label.text, v.currentDegrees, v.nextDegrees)
v.currentDegrees = v.nextDegrees
}
}
})
// start and immediately pause the animation
animator.startAnimation()
animator.pauseAnimation()
case .changed:
// pan gesture changed (touch moved), so
//	update the animator progress
animator.fractionComplete = recognizer.translation(in: self).y / discPathRadius
case .ended:
// if we dragged down less than 1/3rd of the way (or dragged down and back up)
if animator.fractionComplete < 0.333 {
// reverse the animation
animator.isReversed = true
}
animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
// we're no longer dragging
isDragging = false
default:
()
}
}

}


*/

class zScoringOrbitView: UIView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() -> Void {
		// default number of discs
		//numDiscs = 12
		// add the pan gesture
		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
		addGestureRecognizer(panRecognizer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		// only initialize discViews if bounds has changed
		//	(or when forced by numDiscs being set)
		if bounds.width != thisWidth {
			thisWidth = bounds.width
			// assuming we're a 1:1 ratio view
			//  using "center disc" radius of width * 0.2 will allow all discs to fit
			centerDiscRadius = bounds.width * 0.2
			// radius for "orbit" path
			discPathRadius = centerDiscRadius * 1.75
			// init all discs at "center disc" size, centered in self
			discViews.forEach { disc in
				disc.frame = CGRect(origin: .zero, size: CGSize(width: centerDiscRadius * 2.0, height: centerDiscRadius * 2.0))
				disc.center = CGPoint(x: bounds.midX, y: bounds.midY)
			}
		}
	}
	
	private var maxScore: CGFloat = 0
	
	public var scores: [CGFloat] = [] {
		didSet {
			// clear any existing discs
			subviews.forEach {
				$0.removeFromSuperview()
			}
			discViews.removeAll()
			// get the max score
			if let mx = scores.max() {
				maxScore = mx
			}
			// create new discs
			scores.forEach { val in
				let v = ScoreDiscView()
				v.label.text = "\(val)"
				v.score = val
				v.scorePct = val / maxScore
				addSubview(v)
				discViews.append(v)
			}
			guard let v = discViews.last else {
				fatalError("We didn't add any Discs!")
			}
			activeDisc = v
			// trigger layout
			thisWidth = 0
			setNeedsLayout()
		}
	}
	
	private var spacingDegrees: Double = 42.0
	
	/*
	public var numDiscs: Int = 0 {
		didSet {
			// clear any existing discs
			subviews.forEach {
				$0.removeFromSuperview()
			}
			discViews.removeAll()
			// create new discs
			for i in 1...numDiscs {
				let v = DiscView()
				v.label.text = "\(i)"
				addSubview(v)
				discViews.append(v)
			}
			guard let v = discViews.last else {
				fatalError("We didn't add any Discs!")
			}
			activeDisc = v
			// trigger layout
			thisWidth = 0
			setNeedsLayout()
		}
	}
	*/
	
	// used in layoutSubviews
	private var thisWidth: CGFloat = 0
	
	// scale for disc at 6 o'clock
	private let maxScale: CGFloat = 0.60
	private let minScale: CGFloat = 0.10
	private let scaleRange: CGFloat = 0.50
	
	// "center disc" radius, set in layoutSubviews
	private var centerDiscRadius: CGFloat = 0
	
	// radius for "orbit" path, set in layoutSubviews
	private var discPathRadius: CGFloat = 0
	
	// array of "discs"
	private var discViews: [ScoreDiscView] = []
	
	// the disc "on top of the stack" that can be dragged
	private var activeDisc: ScoreDiscView!
	
	private var animator = UIViewPropertyAnimator()
	
	// we only want to drag if the touch starts inside the center disc
	private var isDragging: Bool = false
	
	@objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
		// make sure we're not on the last disc
		guard let idx = discViews.firstIndex(of: activeDisc),
			  idx > 0
		else {
			return
		}
		switch recognizer.state {
		case .began:
			// make sure the drag starts inside the center disc
			let pth = UIBezierPath(ovalIn: discViews[0].frame)
			let pt = recognizer.location(in: self)
			if !pth.contains(pt) {
				return
			}
			isDragging = true
			
			// starting position of disc to drag
			let startPosY = activeDisc.center.y
			
			// create new animator
			animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
			
			// we're moving activeDisc only vertically
			//	and scaling down from 1.0 to first scale size
			animator.addAnimations {
				self.activeDisc.center.y = startPosY + self.discPathRadius
				let sc: CGFloat = self.minScale + (self.activeDisc.scorePct * self.scaleRange)
				self.activeDisc.transform = CGAffineTransform(scaleX: sc, y: sc)
			}
			// handle discs that have already been dragged off the center
			var nextIDX = idx + 1
			// scale for next disc
			//	this will reduce for each successive disc
			var newScale: CGFloat = maxScale
			// degrees to the next disc's final position
			//	this will reduce for each successive disc
			var spacingDegrees: Double = 42.0
			// starting point: 90 degrees
			var startDegrees: Double = 90.0
			// ending point
			var endDegrees: Double = 0
			// we need the same number of keyframes as points for the vertical drag
			let numSteps: CGFloat = discPathRadius
			if nextIDX < discViews.count {
				animator.addAnimations {
					while nextIDX < self.discViews.count {
						let prevDisc = self.discViews[nextIDX - 1]
						let nextDisc = self.discViews[nextIDX]
						// get the next disc
						let d1: Double = Double(((prevDisc.transform.a + 0.4) * 21.0))
						let d2: Double = Double(((nextDisc.transform.a + 0.4) * 21.0))
						spacingDegrees = d1 + d2 // Double((prevDisc.scorePct * 21.0) + (nextDisc.scorePct * 21.0))
						print(prevDisc.scorePct, nextDisc.scorePct, spacingDegrees)
						UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
							endDegrees = startDegrees - spacingDegrees
							let stepDegrees: Double = (startDegrees - endDegrees) / Double(numSteps)
							for i in 1...Int(numSteps) {
								// decrement degrees by step value
								startDegrees -= stepDegrees
								// get point on discPathRadius circle
								let p = CGPoint.pointOnCircle(center: self.discViews[0].center, radius: self.discPathRadius, angle: CGFloat(startDegrees.degreesToRadians))
								// duration is 1 divided by number of steps
								let duration = 1.0 / Double(numSteps)
								// start time for this frame is duration * this step
								let startTime = duration * Double(i)
								// add the keyframe
								UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: duration) {
									nextDisc.center = p
								}
							}
							//startDegrees = endDegrees
							// as we move around the circle, the scales will decrease, so
							//	decrease the distance for each successive disc
							//spacingDegrees *= 0.925
						})
						nextIDX += 1
					}
				}
			}
			// add completion block
			animator.addCompletion({ b in
				// if we animated forward to the end
				if b == .end {
					// set new active disc
					self.activeDisc = self.discViews[idx - 1]
					// hide any discs with scale smaller than 0.1 (10%)
					self.discViews.forEach { v in
						v.isHidden = v.transform.a < 0.1
					}
				}
			})
			// start and immediately pause the animation
			animator.startAnimation()
			animator.pauseAnimation()
		case .changed:
			// pan gesture changed (touch moved), so
			//	update the animator progress
			animator.fractionComplete = recognizer.translation(in: self).y / discPathRadius
		case .ended:
			// if we dragged down less than 1/3rd of the way (or dragged down and back up)
			if animator.fractionComplete < 0.333 {
				// reverse the animation
				animator.isReversed = true
			}
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			// we're no longer dragging
			isDragging = false
		default:
			()
		}
	}
	
}
