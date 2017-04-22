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
    
    private static let APIKey = "JjO607CBtb3LO7PZzQrhA6Mu4I8Kh-FWuwppjc2l"
    private static let APIURL = "http://10.3.125.234/api/"
    private static let LightsEndPoint = "/lights/"
    
    
    private var lights: [Light]? {
        didSet {
            print(lights?.count ?? 0)
        }
    }
    
//    var jsonData = try? JSONSerialization.data(withJSONObject: ["effect": "colorloop", "on"])
    
    private func getLights() {
        guard let url = URL(string: ViewController.APIURL + ViewController.APIKey + ViewController.LightsEndPoint) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = Method.get.rawValue
//        request.httpBody = jsonData
        
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
    

    

    @IBAction func didTapButton(_ sender: Any) {
        getLights()
        print("did tap button")
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

