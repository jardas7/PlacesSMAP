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
    
    @IBOutlet weak var btnSwitch: UISwitch!
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSwitch.isOn = false
    }
    
    
    @IBAction func zmacknuto(_ sender: Any) {
        MapsViewController.GlobalVariable.init(zmacknuto: i)
        i += 1
        print(zmacknuto)
    }
    
}

func showAnno (){
    var data = readDataFromCSV(fileName: "test", fileType: "csv")
    data = cleanRows(file: data!)
    let csvRows = csv(data: data!)
    
    var i = 1
    
    for radek in csvRows {
        if i < csvRows.count {
            let annotation = MKPointAnnotation()
            annotation.title = radek[2]
            //You can also add a subtitle that displays under the annotation such as
            annotation.subtitle = radek[3]
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(radek[1]) as! CLLocationDegrees, longitude: Double(radek[0]) as! CLLocationDegrees)
            //w.addAnnotation(annotation)
        }
        i += 1
        
    } // UXM n. 166/167
    
}

func readDataFromCSV(fileName:String, fileType: String)-> String!{
    guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
        else {
            return nil
    }
    do {
        var contents = try String(contentsOfFile: filepath, encoding: .utf8)
        contents = cleanRows(file: contents)
        return contents
    } catch {
        print("File Read Error for file \(filepath)")
        return nil
    }
}

func csv(data: String) -> [[String]] {
    var result: [[String]] = []
    let rows = data.components(separatedBy: "\n")
    for row in rows {
        let columns = row.components(separatedBy: ",")
        result.append(columns)
    }
    return result
}

func cleanRows(file:String)->String{
    var cleanFile = file
    cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
    cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
    //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
    //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
    return cleanFile
}
