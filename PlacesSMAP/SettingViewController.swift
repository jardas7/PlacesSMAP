//
//  SettingViewController.swift
//  PlacesSMAP
//
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
    
    // Kontrola toho, jestli se state UISwitch změnil, abychom nevolali metodu pro vykreslení anotací dokola
    override func viewWillAppear(_ animated: Bool) {
        valueChanged = false
        defaults.set(valueChanged, forKey: "valueChanged")
    }
    
    // Sledování chování UISwitch a předání do MapsView Controlleru
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
    }
    
}
