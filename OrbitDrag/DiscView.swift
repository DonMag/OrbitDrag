//
//  DiscView.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class DiscView: UIView {
	
	var score: Double = 0
	var scorePct: Double = 0
	var currentDegrees: Double = 90
	var nextDegrees: Double = 90

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
		label.textAlignment = .center
		label.font = .systemFont(ofSize: 30.0)
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.5
		label.numberOfLines = 1
		addSubview(label)
		
		var c: NSLayoutConstraint!
		
		// use .priority == 999 to avoid auto-layout warnings on init
		c = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0)
		c.priority = UILayoutPriority(rawValue: 999)
		c.isActive = true
		c = label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0)
		c.priority = UILayoutPriority(rawValue: 999)
		c.isActive = true
		
		c = label.centerYAnchor.constraint(equalTo: centerYAnchor)
		c.isActive = true
		
		layer.borderWidth = 1
		layer.borderColor = UIColor.blue.cgColor
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.width * 0.5
	}
	
}

