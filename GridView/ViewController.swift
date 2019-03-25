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
    @IBOutlet var labelWithView: UIView!
    @IBOutlet var label: UILabel!
    @IBOutlet var toggleAnimatedButton: UIButton!
    var animated: Bool = true {
        didSet {
            if animated {
                toggleAnimatedButton.setTitle("Toggle Animated Off", for: .normal)
            } else {
                toggleAnimatedButton.setTitle("Toggle Animated On", for: .normal)
            }
        }
    }
    var changeLabelIndex = 0
    let cellNib = UINib(nibName: "ContactLeadNewCell", bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        animated = true
    }

    @IBAction func toggleShowHide() {
        func update() {
            if let firstView = flowView.subviews.first {
                firstView.isHidden = !firstView.isHidden
            }
        }
        animateIfNeed(update: update)
    }
    
    @IBAction func changeLabelText() {
        func update() {
            changeLabelIndex = changeLabelIndex % 5
            changeLabelIndex = changeLabelIndex + 1
            
            for i in 0...changeLabelIndex {
                label.text = (label.text ?? "") + " Label"
            }
            
            flowView.invalidateSubviewSize(view: labelWithView)
        }
        animateIfNeed(update: update)
    }
    
    func animateIfNeed(update:@escaping ()->()) {
        if animated == false {
            update()
        } else {
            UIView.animate(withDuration: 0.3) {
                update()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func toggleAnimated() {
        animated = !animated
    }
    
    @IBAction func delete() {
        func update() {
            if flowView.subviews.count > 0 {
                let randomIndex = 0
                let subview = flowView.subviews[Int(randomIndex)]
                subview.removeFromSuperview()
            }
        }
        animateIfNeed(update: update)
    }
    
    @IBAction func addTagView() {
        func update() {
            let viewToAdd = AIATagView()
            flowView.insertSubview(viewToAdd, at: 0)
        }
        animateIfNeed(update: update)
    }
    
    @IBAction func addContactCard() {
        func update() {
            let viewToAdd = ContactLeadCardIconsView()
            viewToAdd.clipsToBounds = true
            flowView.insertSubview(viewToAdd, at: 0)
        }
        animateIfNeed(update: update)
    }
    
    @IBAction func changeColumnNumber() {
        func update() {
            if flowView.columnNumber == 5 {
                flowView.columnNumber = 1
            } else {
                flowView.columnNumber = flowView.columnNumber + 1
            }
        }
        animateIfNeed(update: update)
    }
}

