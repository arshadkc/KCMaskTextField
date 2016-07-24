//
//  CustomViewController.swift
//  DateTextFieldDemo
//
//  Created by Arshad KC.
//  Copyright © 2016 Arshad KC. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController {

    @IBOutlet weak var maskTextField: KCMaskTextField!
    
    @IBOutlet weak var formatField: UITextField!
    @IBOutlet weak var maskField: UITextField!
    @IBOutlet weak var caseField: UITextField!
    
    
    @IBOutlet weak var formatColorField: KCMaskTextField!
    @IBOutlet weak var maskColorField: KCMaskTextField!
    @IBOutlet weak var textColorField: KCMaskTextField!
    
    
    @IBOutlet weak var componentLabel: UILabel!
    @IBOutlet weak var editedTextLabel: UILabel!
    @IBOutlet weak var rawTextLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatColorField.maskDelegate = self
        maskColorField.maskDelegate = self
        textColorField.maskDelegate = self
        
        maskTextField.maskDelegate = self
        
        formatColorField.updateText("000000")
        maskColorField.updateText("000000")
        textColorField.updateText("000000")
        
        maskTextField.setFormat(formatField.text ?? "", mask: maskField.text ?? "")
    }
}

extension CustomViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let str = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        maskTextField.clearText()
        
        if textField == formatField {
            maskTextField.formatString = str
        }
        else if textField == maskField {
            maskTextField.maskString = str
        }
        else if textField == caseField {
            maskTextField.caseString = str
        }
        else {
            
        }
        return true
    }
}

extension CustomViewController: KCMaskFieldDelegate {
    func maskFieldDidChangeCharacter(maskField: KCMaskTextField) {
        let comp = maskField.textComponents()
        let status = maskField.status()
        // Status
        var statusColor =  UIColor.clearColor()
        switch status {
        case .Clear:
            statusColor = UIColor.lightGrayColor()
        case .Incomplete:
            statusColor = UIColor.redColor()
        case .Complete:
            statusColor = UIColor.greenColor()
        }
        
        statusView.backgroundColor = statusColor
        
        if maskField == maskTextField {
            componentLabel.text = "Components: \(comp)"
            editedTextLabel.text = "Edited Text: \(maskField.editedText())"
            rawTextLabel.text = "Raw Text: \(maskField.rawText())"
        }
        else {
            let r = Int(comp[0], radix: 16)
            let g = Int(comp[1], radix: 16)
            let b = Int(comp[2], radix: 16)
            
            let color = UIColor(colorLiteralRed: Float((r ?? 0))/255.0, green: Float((g ?? 0))/255.0, blue: Float((b ?? 0))/255.0, alpha: 1.0)
            
            if maskField == formatColorField {
                maskTextField.formatColor = color
            }
            else if maskField == self.maskColorField {
                maskTextField.delimiterColor = color
            }
            else if maskField == textColorField {
                maskTextField.editableColor = color
            }
        }
    }
}
