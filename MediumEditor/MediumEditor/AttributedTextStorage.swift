//
//  AttfibutedTextStorage.swift
//  MediumEditor
//
//  Created by Matthew Bain on 24/05/2015.
//  Copyright (c) 2015 Codeghost Ltd. All rights reserved.
//

import UIKit

class AttributedTextStorage: NSTextStorage {
    let backingStore = NSMutableAttributedString()
    var style = UIFontTextStyleBody
    var trait: UIFontDescriptorSymbolicTraits?
    var indent = 0.0
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributesAtIndex(index: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
        return backingStore.attributesAtIndex(index, effectiveRange: range)
    }
    
    override func replaceCharactersInRange(range: NSRange, withString str: String) {
        beginEditing()
        backingStore.replaceCharactersInRange(range, withString:str)
        edited(.EditedCharacters | .EditedAttributes, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    func applyStyle(searchRange: NSRange) {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(style)
        let font = UIFont.preferredFontForTextStyle(style)
        
        let regexStr = "^(.*)$"
        let regex = NSRegularExpression(pattern: regexStr, options: nil, error: nil)!
        let attrs = self.createAttributesForFontStyle(style, withTrait: trait)
        
        regex.enumerateMatchesInString(backingStore.string, options: nil, range: searchRange) {
            match, flags, stop in
            let matchRange = match.rangeAtIndex(1)
            self.addAttributes(attrs, range: matchRange)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = CGFloat(self.indent)
            paragraphStyle.headIndent = CGFloat(self.indent)
            if self.style == UIFontTextStyleHeadline {
                paragraphStyle.paragraphSpacing = CGFloat(0.0)
            } else {
                paragraphStyle.paragraphSpacing = CGFloat(5.0)
            }
            self.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: matchRange)
        }
    }
    
    func performReplacementsForRange(changedRange: NSRange) {
        var extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(changedRange.location, 0)))
        extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(NSMaxRange(changedRange), 0)))
        applyStyle(extendedRange)
    }
    
    override func processEditing() {
        performReplacementsForRange(self.editedRange)
        super.processEditing()
    }
    
    func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits?) -> [NSObject : AnyObject] {
        var fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(style)

        if trait != nil {
            fontDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(trait!)!
        }
        
        let font = UIFont(descriptor: fontDescriptor, size: 0)
        return [NSFontAttributeName : font]
    }
    
    func resetAttributes() {
        style = UIFontTextStyleBody
        trait = nil
        indent = 0.0
    }
}
