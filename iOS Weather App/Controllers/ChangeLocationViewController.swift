//
//  ChangeLocationViewController.swift
//  iOS Weather App
//
//  Created by Ivan Su on 3/5/19.
//  Copyright © 2019 Ivan Su. All rights reserved.
//

import UIKit

class ChangeLocationViewController: UIViewController {
    
    @IBOutlet weak var containerSearchTextField: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var delegate: ReceivedSearchLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        delegate?.receiveSearchValue(val: searchTextField.text!)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
