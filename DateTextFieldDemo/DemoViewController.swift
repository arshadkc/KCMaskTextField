//
//  ViewController.swift
//  DateTextFieldDemo
//
//  Created by Arshad KC.
//  Copyright © 2016 Arshad KC. All rights reserved.
//

import UIKit

struct Formation {
    struct Custom {
        static let format = "( [ABCD-1234-XXXX-5678] - [MM/DDDD] - [CVV] )"
        static let mask = "***aaaa*dddd*....*dddd*****dd*dddd*****ddd***"
        static let cas = "***AAAA*dddd*aaaa*dddd*****dd*dddd*****ddd***"
    }
    struct Date1 {
        static let format1 = "MM/DD/YY"
        static let format2 = "MM-DD-YY"
        static let mask    = "dd*dd*dd"
    }
    struct Date2 {
        static let format1 = "MM/DD/YYYY"
        static let format2 = "MM-DD-YYYY"
        static let mask    = "dd*dd*dddd"
    }
    struct HexColor {
        static let format1 = "#RRGGBBAA"
        static let mask    = "*hhhhhhhh"
    }
    struct CreditCardVisa {
        static let format1 = "XXXX-XXXX-XXXX-XXXX"
        static let format2 = "XXXX XXXX XXXX XXXX"
        static let mask    = "dddd*dddd*dddd*dddd"
    }
    struct CreditCardExpiry {
        static let format1 = "MM/YY"
        static let mask    = "dd*dd"
    }
    struct CreditCardCVV {
        static let format1 = "CVV"
        static let mask    = "ddd"
    }
    struct PhoneNumber {
        static let format1 = "+91 __________ ( India )"
        static let mask    = "****dddddddddd**********"
    }
}

class DemoViewController: UIViewController {

    @IBOutlet weak var dateTextField: KCMaskTextField!
    @IBOutlet weak var hexColorField: KCMaskTextField!
    
    @IBOutlet weak var creditCardNumberField: KCMaskTextField!
    @IBOutlet weak var creditCardExpiryField: KCMaskTextField!
    @IBOutlet weak var creditCardCVVField: KCMaskTextField!
    @IBOutlet weak var phoneNumberField: KCMaskTextField!
    @IBOutlet weak var customField: KCMaskTextField!
    
    // Status views
    @IBOutlet weak var dateStatusView: UIView!
    @IBOutlet weak var hexColorStatusView: UIView!
    @IBOutlet weak var cardNumberStatusView: UIView!
    @IBOutlet weak var cardExpiryStatusView: UIView!
    @IBOutlet weak var cardCVVStatusView: UIView!
    @IBOutlet weak var phoneNumberStatusView: UIView!
    @IBOutlet weak var customStatusView: UIView!
    
    @IBOutlet weak var componentsLabel: UILabel!
    @IBOutlet weak var editedLabel: UILabel!
    @IBOutlet weak var rawLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dateTextField.maskDelegate = self
        dateTextField.setFormat(Formation.Date1.format1, mask: Formation.Date1.mask)
        dateTextField.becomeFirstResponder()
        
        hexColorField.maskDelegate = self
        hexColorField.setFormat(Formation.HexColor.format1, mask: Formation.HexColor.mask)
        hexColorField.delimiterColor = UIColor.blackColor()
        
        creditCardNumberField.maskDelegate = self
        creditCardNumberField.setFormat(Formation.CreditCardVisa.format1, mask: Formation.CreditCardVisa.mask)
        creditCardNumberField.formatColor = UIColor.orangeColor()

        creditCardExpiryField.maskDelegate = self
        creditCardExpiryField.setFormat(Formation.CreditCardExpiry.format1, mask: Formation.CreditCardExpiry.mask)
        creditCardExpiryField.formatColor = UIColor.orangeColor()
        
        creditCardCVVField.maskDelegate = self
        creditCardCVVField.setFormat(Formation.CreditCardCVV.format1, mask: Formation.CreditCardCVV.mask)
        creditCardCVVField.formatColor = UIColor.orangeColor()
        
        phoneNumberField.maskDelegate = self
        phoneNumberField.setFormat(Formation.PhoneNumber.format1, mask: Formation.PhoneNumber.mask)
        phoneNumberField.delimiterColor = UIColor.blueColor()
        
        customField.maskDelegate = self
        customField.setFormat(Formation.Custom.format, mask: Formation.Custom.mask)
        customField.caseString = Formation.Custom.cas
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClearAll(sender: AnyObject) {
        dateTextField.clearText()
        updateUI(dateTextField)
        
        hexColorField.clearText()
        updateUI(hexColorField)
        
        dateTextField.clearText()
        updateUI(dateTextField)
        
        creditCardNumberField.clearText()
        updateUI(creditCardNumberField)
        
        creditCardExpiryField.clearText()
        updateUI(creditCardExpiryField)
        
        creditCardCVVField.clearText()
        updateUI(creditCardCVVField)
        
        phoneNumberField.clearText()
        updateUI(phoneNumberField)
        
        customField.clearText()
        updateUI(customField)
        
        dateTextField.becomeFirstResponder()
    }
}

extension DemoViewController:KCMaskFieldDelegate {
    func maskFieldDidBeginEditing(maskField: KCMaskTextField) {
        updateUI(maskField)
    }
    
    func maskFieldDidEndEditing(maskField: KCMaskTextField) {
    }
    
    func maskFieldDidChangeCharacter(maskField: KCMaskTextField) {
        updateUI(maskField)
    }
    
    private func updateUI(maskField:KCMaskTextField) {
        
        editedLabel.text = "Edited Text: \(maskField.editedText())"
        rawLabel.text = "Raw: \(maskField.rawText())"
        
        let comp = maskField.textComponents()
        componentsLabel.text = "Components: \(comp)"
        
        let status  = maskField.status()
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
        
        if maskField == dateTextField {
            dateStatusView.backgroundColor = statusColor
        }
        else if maskField == hexColorField {
            hexColorStatusView.backgroundColor = statusColor
            if maskField.status() == .Complete {
                let text = maskField.editedText()
                
                let c1 = text[text.startIndex ..< text.startIndex.advancedBy(2)]
                let r = Int(c1, radix: 16)
                let c2 = text[text.startIndex.advancedBy(2) ..< text.startIndex.advancedBy(4)]
                let g = Int(c2, radix: 16)
                let c3 = text[text.startIndex.advancedBy(2) ..< text.startIndex.advancedBy(6)]
                let b = Int(c3, radix: 16)
                let c4 = text[text.startIndex.advancedBy(2) ..< text.startIndex.advancedBy(8)]
                let a = Int(c4, radix: 16)
                
                let color = UIColor(colorLiteralRed: Float(r!)/255.0, green: Float(g!)/255.0, blue: Float(b!)/255.0, alpha: Float(a!)/255.0)
                maskField.delimiterColor = color
            }
        }
        else if maskField == creditCardNumberField {
            cardNumberStatusView.backgroundColor = statusColor
        }
        else if maskField == creditCardExpiryField {
            cardExpiryStatusView.backgroundColor = statusColor
        }
        else if maskField == creditCardCVVField {
            cardCVVStatusView.backgroundColor = statusColor
        }
        else if maskField == phoneNumberField {
            phoneNumberStatusView.backgroundColor = statusColor
        }
        else if maskField == customField {
            customStatusView.backgroundColor = statusColor
        }
    }
}

