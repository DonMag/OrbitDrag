//
//  ViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let testView = OrbitView()
		testView.translatesAutoresizingMaskIntoConstraints = false
		testView.backgroundColor = .systemGreen
		view.addSubview(testView)
		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			testView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0),
			testView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0),
			testView.heightAnchor.constraint(equalTo: testView.widthAnchor),
			testView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
		])
		
		testView.numDiscs = 16
		
	}

	/*
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let testView = ScoringOrbitView()
		testView.translatesAutoresizingMaskIntoConstraints = false
		testView.backgroundColor = .systemGreen
		view.addSubview(testView)
		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			testView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0),
			testView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0),
			testView.heightAnchor.constraint(equalTo: testView.widthAnchor),
			testView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
		])
		
		testView.scores = [
			30, 30, 30,
			50, 50, 50,
			60, 60,
			80, 90,
			100,
		].reversed()
		
	}
	*/
	
}

