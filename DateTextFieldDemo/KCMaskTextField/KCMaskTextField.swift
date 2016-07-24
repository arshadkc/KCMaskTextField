//
//  DateTextField.swift
//  DateTextFieldDemo
//
//  Created by Arshad KC.
//  Copyright © 2016 Arshad KC. All rights reserved.
//

import Foundation
import UIKit

enum KCMaskTextFieldStatus {
    case Clear
    case Incomplete
    case Complete
}

struct Delimiter {
    static let value:Character = "*"
}

struct KCChar {
    var format:Character
    var value:Character
    var isClear:Bool
    var type:Character

    init(format:Character, type:Character) {
        self.format = format
        self.value = format
        self.type = type
        self.isClear = true
    }
    
    var isEditable:Bool {
        return type != Delimiter.value
    }
}

class KCMaskTextField: UITextField {
    // Private
    private var chars:Array<KCChar> = Array<KCChar>()
    private var previousCursorPosition = 0
    
    // Delegate
    var maskDelegate: KCMaskFieldDelegate?
    
    // Color for mask values. ex: DD,MM and YY in DD/MM/YY
    @IBInspectable var formatColor:UIColor = UIColor.grayColor(){
        didSet {
            displayFormattedText()
            moveCursorTo(previousCursorPosition)
        }
    }
    
    // Color for delimiterColor values. ex: /,/ in DD/MM/YY
    @IBInspectable var delimiterColor:UIColor = UIColor.grayColor(){
        didSet {
            displayFormattedText()
            moveCursorTo(previousCursorPosition)
        }
    }
    
    // Color for editable values. ex: 22,01,17 in 22/01/17
    @IBInspectable var editableColor:UIColor = UIColor.blackColor(){
        didSet {
            displayFormattedText()
            moveCursorTo(previousCursorPosition)
        }
    }
    
    // Format string. ex: MM/DD/YYYY
    @IBInspectable var formatString:String = "" {
        didSet {
            initialize()
        }
    }
    
    //     d	: Number, decimal number from 0 to 9
    //     D	: Any symbol, except decimal number
    //     a	: Alphabetic symbol, a-Z
    //     A	: Not an alphabetic symbol
    //     c    : Alphanumeric a-z,0-9
    //     C    : Not an alphanumeric symbol
    //     h	: Hexadecimal symbol
    //     .	: Corresponds to any symbol (default)
    //     *	: Non editable field

    // Mask string. ex: dd*dd*dd
    @IBInspectable var maskString:String = "" {
        didSet {
            initialize()
        }
    }
    
    ///     a	: Display in lower case
    ///     A	: Display in upper case
    @IBInspectable var caseString:String = "" {
        didSet {
        }
    }

    private func initialize() {
        // Set delegate ot self
        self.delegate = self
        chars.removeAll()
        for (index,c) in formatString.characters.enumerate() {
            // Create KCChar
            let m = index < maskString.characters.count ? maskString.characters[formatString.characters.startIndex.advancedBy(index)] : "."
            let sq = KCChar(format: c, type:m)
            chars.append(sq)
        }
        // Display formation
        displayFormattedText()
        // Set initial cursor position
        previousCursorPosition = findLocationForward(fromLocation: 0) ?? 0
    }
}

// MARK: - Public methods
extension KCMaskTextField {
    /**
     Returns status of the mask field (.Clear, .InComplete, .Complete ).
     */
    func status() -> KCMaskTextFieldStatus {
        let editableChars = chars.filter {$0.isEditable}
        let completedChar = editableChars.filter {!$0.isClear}.count
        return completedChar == editableChars.count ? .Complete : completedChar == 0 ? .Clear : .Incomplete
    }

    /**
     Returns an array of values for each component.
     */
    func textComponents() -> [String] {
        var components = [String]()
        var str = String()
        var count  = 0
        for (index,ch) in chars.enumerate() {
            if ch.isEditable {
                str = str + (ch.isClear ? "" : String(ch.value))
                count += 1
            }
            if (!ch.isEditable || index == chars.count - 1 ) && count > 0 {
                components.append(str)
                str.removeAll()
                count = 0
                continue
            }
        }
        return components
    }
    
    /**
     Returns the string displayed in the mask field as it is.
     */
    func rawText() -> String {
        return chars.map {String($0.value)}.reduce("", combine: {$0 + $1})
    }
    
    /**
     Returns the values entered in mask field.
     */
    func editedText() -> String {
        return chars.filter{$0.isEditable && !$0.isClear}.map{String($0.value)}.reduce("", combine: {$0 + $1})
    }
    
    /**
     Updates the text
     */
    func updateText(text:String) {
        guard text.characters.count > 0 else {
            return
        }
        textField(self, shouldChangeCharactersInRange: NSMakeRange(0,0), replacementString: text)
    }
    
    /**
     Clears the text. This does not clear any format/mask/case.
     */
    func clearText() {
        for (index,ch) in chars.enumerate() {
            if !ch.isClear {
                chars[index].value = chars[index].format
                chars[index].isClear = true
            }
        }
        displayFormattedText()
        previousCursorPosition = findLocationForward(fromLocation: 0) ?? 0
        moveCursorTo(previousCursorPosition)
    }
    
    /**
     Sets format and mask for mask field
     */
    func setFormat(format:String, mask:String) {
        formatString = format
        maskString = mask
    }
}

//  MARK: - Textfield Delegate
extension KCMaskTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        moveCursorTo(previousCursorPosition)
        maskDelegate?.maskFieldDidBeginEditing(self)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        maskDelegate?.maskFieldDidEndEditing(self)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // guard out of bounds
        guard range.location < chars.count else {
            return false
        }
        formatInput(string, range: range)
        return false
    }
    
    private func formatInput(string:String, range:NSRange) {
        var nextCursorPosition = range.location
        let inputLength = string.characters.count
        var edited = false
        // Edit
        if (inputLength > 0) {
            let hasSelection = range.length > 0 && range.length < string.characters.count
            var nextValidLocation:Int = range.location;
            let start = range.location
            let end = start + (range.length == 0 ? string.characters.count : range.length >= string.characters.count ? string.characters.count : range.length)
            var index = 0
            for _ in start ..< end{
                let c = string[string.startIndex.advancedBy(index)]
                if let location = findLocationForward(fromLocation: nextValidLocation) {
                    if hasSelection && location >= end {
                        break
                    }
                    if isValidCharacter(c, atIndex: location) {
                        chars[location].value = c
                        chars[location].isClear = false
                        edited = true
                        nextValidLocation  = location + 1
                    }
                }
                index+=1
            }
            
            // If there is any insertion or replacement, update the display and cursor.
            if (edited) {
                displayFormattedText()
                nextCursorPosition = nextValidLocation
            }
        }
        // Delete & Replace
        else {
            // Clear
            let start = range.location
            let end = (range.location + range.length)
            for i in start ..< end {
                if chars[i].isEditable {
                    chars[i].value = chars[i].format
                    if !chars[i].isClear {
                        chars[i].isClear = true
                        edited = true
                    }
                }
            }
            
            displayFormattedText()
            
            // Find next valid cursor position.
            if let location = findLocationBackward(fromLocation: range.location-1) {
                nextCursorPosition = location + 1
            }
            else {
                nextCursorPosition = findLocationForward(fromLocation: range.location) ?? range.location
            }
        }
        
        // Update new cursor position.
        moveCursorTo(nextCursorPosition)
        
        // Inform the delegate if the field is edited ( insert,replace,delete )
        if edited  {
            maskDelegate?.maskFieldDidChangeCharacter(self)
        }
    }
    
    private func moveCursorTo(position:Int) {
        if let newCursorPosition = self.positionFromPosition(self.beginningOfDocument, offset:position) {
            let newSelectedRange = self.textRangeFromPosition(newCursorPosition, toPosition:newCursorPosition)
            self.selectedTextRange = newSelectedRange
        }
        previousCursorPosition = position
    }
    
    private func findLocationForward(fromLocation location:Int) -> Int? {
        var nextLocation:Int?
        for i in location ..< chars.count {
            if chars[i].isEditable {
                nextLocation = i
                break
            }
        }
        return nextLocation
    }
    
    private func findLocationBackward(fromLocation location:Int) -> Int? {
        var nextLocation:Int?
        for i in location.stride(to: -1, by: -1) {
            if chars[i].isEditable {
                nextLocation = i
                break
            }
        }
        return nextLocation
    }
    
}

//  MARK: - Display
extension KCMaskTextField {
    private func displayFormattedText() {
        // clear placeholder 
        placeholder = ""
        
        let myAttribute = [ NSForegroundColorAttributeName : UIColor.blackColor() ]
        let mString = NSMutableAttributedString(string: "", attributes: myAttribute )

        for (index,ch) in chars.enumerate() {
            var color  = UIColor.blackColor()
            if !ch.isEditable {
                color = delimiterColor
            }
            else if ch.isClear {
                color = formatColor
            }
            else {
                color = editableColor
            }
            var s = String(ch.value)
            
            // Update character case
            if ch.isEditable && !ch.isClear {
                let caseFormat:Character? = caseString.characters.count == 1 ? caseString.characters.first! : (index < caseString.characters.count ? caseString.characters[caseString.characters.startIndex.advancedBy(index)] : nil)
                if let c = caseFormat {
                    switch c {
                    case "a":
                        s = s.lowercaseString
                        chars[index].value = s.characters.first!
                    case "A":
                        s = s.uppercaseString
                        chars[index].value = s.characters.first!
                    default:
                        break
                    }
                }
            }
            
            let aString = NSAttributedString(string: s, attributes: [NSForegroundColorAttributeName:color])
            mString.appendAttributedString(aString)
        }
        self.attributedText = mString
    }
}

//  MARK: - Validation

//     d	: Number, decimal number from 0 to 9
//     D	: Any symbol, except decimal number
//     a	: Alphabetic symbol, a-Z
//     A	: Not an alphabetic symbol
//     c    : Alphanumeric a-z,0-9
//     C    : Not an alphanumeric symbol
//     h	: Hexadecimal symbol
//     .	: Corresponds to any symbol (default)
//     *	: Non editable field
extension KCMaskTextField {
    private func isValidCharacter(character:Character, atIndex index:Int) -> Bool {
        let char = chars[index]
        let uni = String(character).unicodeScalars
        var isValidType = false
        switch char.type {
        case "d":
            isValidType = NSCharacterSet.decimalDigitCharacterSet().longCharacterIsMember(uni[uni.startIndex].value)
            break
        case "D":
            isValidType = !NSCharacterSet.decimalDigitCharacterSet().longCharacterIsMember(uni[uni.startIndex].value)
            break
        case "A":
            isValidType = !NSCharacterSet.letterCharacterSet().longCharacterIsMember(uni[uni.startIndex].value)
            break
        case "a":
            isValidType = NSCharacterSet.letterCharacterSet().longCharacterIsMember(uni[uni.startIndex].value)
            break
        case "c":
            isValidType = NSCharacterSet.alphanumericCharacterSet().longCharacterIsMember(uni[uni.startIndex].value)
            break
        case "C":
            isValidType = !NSCharacterSet.alphanumericCharacterSet().longCharacterIsMember(uni[uni.startIndex].value)
            break
        case "h":
            isValidType = NSCharacterSet(charactersInString: "0123456789abcdefABCDEF").longCharacterIsMember(uni[uni.startIndex].value)
            break
        case ".":
            isValidType = true
            break
        default:
            isValidType = false
            break
        }
        return isValidType
    }
}

//  MARK: - KCMaskFieldDelegate
protocol KCMaskFieldDelegate : class  {
    
    /// Tells the delegate that editing began for the specified mask field.
    func maskFieldDidBeginEditing(maskField: KCMaskTextField)
    
    /// Tells the delegate that editing finished for the specified mask field.
    func maskFieldDidEndEditing(maskField: KCMaskTextField)
    
    /// Tells the delegate that specified mask field change text.
    func maskFieldDidChangeCharacter(maskField: KCMaskTextField)
}

extension KCMaskFieldDelegate {

    func maskFieldDidBeginEditing(maskField: KCMaskTextField) {}
    
    func maskFieldDidEndEditing(maskField: KCMaskTextField) {}
    
    func maskFieldDidChangeCharacter(maskField: KCMaskTextField) {}
}
