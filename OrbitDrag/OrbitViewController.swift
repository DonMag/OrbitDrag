//
//  OrbitViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/23/21.
//

import UIKit

class OrbitViewController: UIViewController {

	var scoresArray: [Double] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white

		let testOrbitView = OrbitView()
		testOrbitView.translatesAutoresizingMaskIntoConstraints = false
		testOrbitView.backgroundColor = .systemYellow
		
		view.addSubview(testOrbitView)

		let g = view.safeAreaLayoutGuide

		NSLayoutConstraint.activate([
			testOrbitView.topAnchor.constraint(equalTo: g.topAnchor, constant: 20.0),
			testOrbitView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0),
			testOrbitView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0),
			testOrbitView.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -20.0),
		])

		testOrbitView.scores = scoresArray
		
    }
    
}
