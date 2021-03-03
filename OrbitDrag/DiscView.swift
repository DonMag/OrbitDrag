//
//  DiscView.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

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

