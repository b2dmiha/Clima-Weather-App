//
//  ChangeCityViewController.swift
//  Clima
//
//  Created by Michael Gimara on 27/03/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

class ChangeCityViewController: UIViewController {
    
    //MARK: - Variables
    var delegate: ChangeCityDelegate?
    
    //MARK: - Outlets
    @IBOutlet weak var changeCityTextField: UITextField!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Actions
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        if let cityName = changeCityTextField.text {
            delegate?.userEnteredANewCityName(city: cityName)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
