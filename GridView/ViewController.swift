//
//  ViewController.swift
//  GridView
//
//  Created by Yee Chuan Lee on 21/03/2019.
//  Copyright © 2019 Yee Chuan Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var flowView: FlowView!
    let cellNib = UINib(nibName: "ContactLeadNewCell", bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func delete() {
        func update() {
            if flowView.subviews.count > 0 {
                let randomIndex = 0
                let subview = flowView.subviews[Int(randomIndex)]
                subview.removeFromSuperview()
            }
        }
        UIView.animate(withDuration: 0.3) {
            update()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func addTagView() {
        func update() {
            let viewToAdd = AIATagView()
            flowView.insertSubview(viewToAdd, at: 0)
        }
        UIView.animate(withDuration: 0.3) {
            update()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func addContactCard() {
        func update() {
            let viewToAdd = ContactLeadCardIconsView()
            viewToAdd.clipsToBounds = true
            flowView.insertSubview(viewToAdd, at: 0)
        }
        UIView.animate(withDuration: 0.3) {
            update()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func changeColumnNumber() {
        func update() {
            if flowView.columnNumber == 5 {
                flowView.columnNumber = 1
            } else {
                flowView.columnNumber = flowView.columnNumber + 1
            }
        }
        UIView.animate(withDuration: 0.3) {
            update()
            self.view.layoutIfNeeded()
        }
    }
}

