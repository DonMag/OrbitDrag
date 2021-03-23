//
//  ViewController.swift
//  OrbitDrag
//
//  Created by Don Mag on 3/3/21.
//

import UIKit

class ViewController: UIViewController {

	let infoLabel = UILabel()
	let textView = UITextView()
	let goButton = UIButton()
	
	let defaultScores = "60, 60, 75, 75, 75, 80, 90, 100"
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 8

		stack.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stack)

		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: g.topAnchor, constant: 40.0),
			stack.widthAnchor.constraint(equalToConstant: 300.0),
			stack.centerXAnchor.constraint(equalTo: g.centerXAnchor),
		])

		infoLabel.textAlignment = .center
		infoLabel.text = "Enter scores separated by commas..."
		
		textView.layer.borderWidth = 1
		textView.layer.borderColor = UIColor.gray.cgColor
		textView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
		
		goButton.backgroundColor = .red
		goButton.setTitle("Go!", for: [])
		goButton.setTitleColor(.white, for: .normal)
		goButton.setTitleColor(.lightGray, for: .highlighted)
		goButton.addTarget(self, action: #selector(showOrbitVC(_:)), for: .touchUpInside)
		
		stack.addArrangedSubview(infoLabel)
		stack.addArrangedSubview(textView)
		stack.addArrangedSubview(goButton)

	}
	
	@objc func showOrbitVC(_ sender: UIButton) -> Void {

		view.endEditing(true)
		var scores = defaultScores
		if let t = textView.text, t.count > 0 {
			scores = t
		}
		
		var floatArray: [Float] = []
		let aTmp = scores.components(separatedBy: ",")
		aTmp.forEach { v in
			let vv = v.trimmingCharacters(in: .whitespacesAndNewlines)
			if let f = Float(vv) {
				floatArray.append(f)
			}
		}

		if floatArray.count == 0 {
			let vc = UIAlertController(title: "Error", message: "Could not parse scores!", preferredStyle: .alert)
			vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(vc, animated: true, completion: nil)
			return
		}
		
		let vc = OrbitViewController()
		vc.scoresArray = floatArray
		navigationController?.pushViewController(vc, animated: true)

	}

	var isFirstTime: Bool = true
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if isFirstTime {
			let vc = UIAlertController(title: "Please Note!", message: "This is EXAMPLE code only! It should not be considered \"production ready.\"", preferredStyle: .alert)
			vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(vc, animated: true, completion: nil)
		}
	}
}

