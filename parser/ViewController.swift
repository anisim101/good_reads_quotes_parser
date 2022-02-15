//
//  ViewController.swift
//  parser
//
//  Created by Vladimir Anisimov on 27.07.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Parser.shared.parseQuotes(tagName: "feminism", lastPage: 100) { el in
            let jsonEncoder = JSONEncoder()
            guard let data = try? jsonEncoder.encode(el) else { return }
            guard let jsonString = String(data: data, encoding: .utf8) else { return }
            
            print(jsonString)
        }
    }


}

