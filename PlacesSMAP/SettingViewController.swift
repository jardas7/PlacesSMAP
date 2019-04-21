//
//  SettingViewController.swift
//  PlacesSMAP
//
//  Created by Jaromír Hnik on 20/04/2019.
//  Copyright © 2019 Jaromír Hnik. All rights reserved.
//

import Foundation
import MapKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var btnSwitched: UISwitch!
    var press : Int = 1
    let defaults = UserDefaults.standard
    var switchON : Bool = false
    var valueChanged : Bool = false
    var mVC = MapsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSwitched.isOn = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        valueChanged = false
        defaults.set(valueChanged, forKey: "valueChanged")
    }
    
    @IBAction func btnPressed(_ sender: UISwitch) {
        
        if (sender.isOn == true) {
            switchON = true
            defaults.set(switchON, forKey: "switchON")
            valueChanged = true
            defaults.set(valueChanged, forKey: "valueChanged")
        } else {
            switchON = false
            defaults.set(switchON, forKey: "switchON")
            valueChanged = true
            defaults.set(valueChanged, forKey: "valueChanged")
        }
       // print(mVC.tadyCounter)
    }
    
}
