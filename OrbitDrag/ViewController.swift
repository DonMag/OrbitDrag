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

		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 20

		stack.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stack)

		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			stack.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 40.0),
			stack.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -40.0),
			stack.centerYAnchor.constraint(equalTo: g.centerYAnchor),
		])

		["Basic", "Score Based"].forEach { s in
			let b = UIButton()
			b.backgroundColor = .red
			b.setTitle(s, for: [])
			b.setTitleColor(.white, for: .normal)
			b.setTitleColor(.lightGray, for: .highlighted)
			b.addTarget(self, action: #selector(showOrbitVC(_:)), for: .touchUpInside)
			stack.addArrangedSubview(b)
		}
		
	}
	
	@objc func showOrbitVC(_ sender: UIButton) -> Void {
		guard let t = sender.currentTitle else {
			return
		}
		if t == "Basic" {
			let vc = BasicOrbitViewController()
			navigationController?.pushViewController(vc, animated: true)
		} else {
			let vc = ScoreBasedOrbitViewController()
			navigationController?.pushViewController(vc, animated: true)
		}
	}

//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		let testView = OrbitView()
//		testView.translatesAutoresizingMaskIntoConstraints = false
//		testView.backgroundColor = .systemGreen
//		view.addSubview(testView)
//		let g = view.safeAreaLayoutGuide
//		NSLayoutConstraint.activate([
//			testView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0),
//			testView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0),
//			testView.heightAnchor.constraint(equalTo: testView.widthAnchor),
//			testView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
//		])
//
//		testView.numDiscs = 16
//
//	}

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

class BasicOrbitViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
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
	
}

class ScoreBasedOrbitViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white

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
		
		testView.scores = [
			20, 40, 50,
			60, 70, 80,
			90, 100,
		].reversed()
		
		testView.scores = [
			50, 60, 70,
			75, 80, 85,
			90, 95, 100,
		].reversed()
		
		testView.scores = [
			50, 50, 50,
			60, 80, 90,
			90, 90, 100,
		].reversed()
		
		testView.scores = [
			100, 100, 100,
			100, 100, 100,
			100, 100, 100,
		].reversed()
		
	}
	
}

