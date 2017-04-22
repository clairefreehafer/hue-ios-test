//
//  ViewController.swift
//  EasyButton
//
//  Created by Claire Freehafer on 4/22/17.
//  Copyright © 2017 Claire Freehafer. All rights reserved.
//

import UIKit

final class Light {
    let lightName: String
    let isOn: Bool
    let saturation: Int
    let brightness: Int
    let hue: Int
    
    init(lightName: String, isOn: Bool, saturation: Int, brightness: Int, hue: Int) {
        self.lightName = lightName
        self.isOn = isOn
        self.saturation = saturation
        self.brightness = brightness
        self.hue = hue
    }
}

class ViewController: UIViewController {
    enum Method: String {
        case get = "GET"
        case put = "PUT"
    }
    
    // URL variables
    private static let APIKey = "JjO607CBtb3LO7PZzQrhA6Mu4I8Kh-FWuwppjc2l"
    private static let APIURL = "http://10.3.125.234/api/"
    private static let LightsEndPoint = "/lights/"
    private static let State = "/state"
    
    
    private var lights: [Light]? {
        didSet {
            print(lights?.count ?? 0)
        }
    }
    
    // create json to send with put request
//    var randomHue: UInt32 = arc4random_uniform(65535)
    
    
    
    
    private func getLights(lightNum: Int) {
        let jsonData = try? JSONSerialization.data(withJSONObject: [
            "on": true,
            "hue": arc4random_uniform(65536),
            "sat": /*arc4random_uniform(255)*/ 254,
            "bri": /*arc4random_uniform(255)*/ 254
            ])
        
        // URL to send request to
        guard let url = URL(string: ViewController.APIURL + ViewController.APIKey + ViewController.LightsEndPoint + String(lightNum) + "/state/") else { return }
        
        // creating session and request body
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = Method.put.rawValue // type of request
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            
            guard let strongSelf = self else { return }
            
            guard let data = data, error == nil, let responseJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                print("error was \(error)")
                return
            }
            
            if let lightsJSON = responseJSON?["lights"] as? [String: Any] {
                
                strongSelf.lights = lightsJSON.flatMap {
                    
                    guard let lightInfo = $0.value as? [String: Any],
                        let state = lightInfo["state"] as? [String: Any],
                        let isOn = state["on"] as? Bool,
                        let brightness = state["bri"] as? Int,
                        let hue = state["hue"] as? Int,
                        let saturation = state["sat"] as? Int else { return nil }
                    
                    return Light(lightName: $0.key, isOn: isOn, saturation: saturation, brightness: brightness, hue: hue)
                }
            }
            
            let string = String(data: data, encoding: .utf8) ?? ""
            print(string)
        }
        
        task.resume()
    }
    
    
    // convention for variables at the top of the class
    @IBOutlet weak var helloWorldLabel: UILabel!
    
    @IBOutlet weak var easyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        helloWorldLabel.text = "Goodbye World"
        easyButton.setTitle("Easy Button", for: .normal)
    }
    

/*******************************************/
/********** BUTTON EVENT LISTENER **********/
/*******************************************/

    @IBAction func didTapButton(_ sender: Any) {
        for i in 1...3 {
            getLights(lightNum: i)
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

