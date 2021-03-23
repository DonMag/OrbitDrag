//
//  OrbitViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/23/21.
//

import UIKit

class OrbitViewController: UIViewController {

	var scoresArray: [Float] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white

		let testOrbitView = OrbitView()
		testOrbitView.translatesAutoresizingMaskIntoConstraints = false
		testOrbitView.backgroundColor = .systemGreen
		view.addSubview(testOrbitView)

		let g = view.safeAreaLayoutGuide
		
		var c: NSLayoutConstraint!
		
		// constrain view as large as possible with 20-pts on all sides
		//	while keeping it square (1:1 ratio), centered in view
		c = testOrbitView.topAnchor.constraint(equalTo: g.topAnchor, constant: 20.0)
		c.priority = .defaultHigh
		c.isActive = true
		
		c = testOrbitView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0)
		c.priority = .defaultHigh
		c.isActive = true
		
		c = testOrbitView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0)
		c.priority = .defaultHigh
		c.isActive = true
		
		c = testOrbitView.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -20.0)
		c.priority = .defaultHigh
		c.isActive = true
		
		NSLayoutConstraint.activate([
			testOrbitView.topAnchor.constraint(greaterThanOrEqualTo: g.topAnchor, constant: 20.0),
			testOrbitView.leadingAnchor.constraint(greaterThanOrEqualTo: g.leadingAnchor, constant: 20.0),
			testOrbitView.trailingAnchor.constraint(lessThanOrEqualTo: g.trailingAnchor, constant: -20.0),
			testOrbitView.bottomAnchor.constraint(lessThanOrEqualTo: g.bottomAnchor, constant: -20.0),
			testOrbitView.centerXAnchor.constraint(equalTo: g.centerXAnchor),
			testOrbitView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
			testOrbitView.widthAnchor.constraint(equalTo: testOrbitView.heightAnchor),
		])

		testOrbitView.scores = scoresArray
		
    }
    
}
