//
//  MediumEditorViewController.swift
//  MediumEditor
//
//  Created by Matthew Bain on 23/05/2015.
//  Copyright (c) 2015 Codeghost Ltd. All rights reserved.
//

import UIKit

class MediumEditorViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var textViewPlaceholder: UITextView!
    @IBOutlet weak var fontButton: UIBarButtonItem!
    @IBOutlet weak var quoteButton: UIBarButtonItem!
    
    var textView: UITextView!
    var textStorage: AttributedTextStorage!
    
    var delegate: MediumEditorViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createTextView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        textView.frame = textViewPlaceholder.frame
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        let _string =  textView.attributedText.attributedSubstringFromRange(textView.selectedRange)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textStorage.resetAttributes()
            fontButton.tintColor = UIColor.darkGrayColor()
            quoteButton.tintColor = UIColor.darkGrayColor()
        }
        return true
    }
    
    func createTextView() {
        textStorage = AttributedTextStorage()
        
        let newTextViewRect = view.bounds
        let layoutManager = NSLayoutManager()
        let containerSize = CGSize(width: newTextViewRect.width, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)
        
        textView = UITextView(frame: newTextViewRect, textContainer: container)
        textView.delegate = self

        view.addSubview(textView)
    }

    func keyboardWillShow(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size

        self.view.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - keyboardSize.height)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        view.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height + keyboardSize.height)
    }
    
    func preferredContentSizeChanged(sender: NSNotification) {
        
    }

    func forceRedraw() {
        textStorage.performReplacementsForRange(self.textView.selectedRange)
        let cursorPos = self.textView.selectedTextRange
        self.textView.selectedTextRange = cursorPos
    }
    
    @IBAction func toggleFont(sender: AnyObject) {
        let store = textView.textStorage as! AttributedTextStorage
        if store.style == UIFontTextStyleBody {
            store.style = UIFontTextStyleHeadline
            store.indent = 0.0
            store.trait = nil
            fontButton.tintColor = UIColor(red: 25.0/255.0, green: 163.0/255.0, blue: 68.0/255.0, alpha: 1)
            quoteButton.tintColor = UIColor.darkGrayColor()
        } else {
            store.style = UIFontTextStyleBody
            store.indent = 0.0
            store.trait = nil
            fontButton.tintColor = UIColor.darkGrayColor()
        }
        forceRedraw()
    }

    @IBAction func toggleQuote(sender: AnyObject) {
        let store = textView.textStorage as! AttributedTextStorage
        if store.indent == 0.0 {
            store.indent = 20.0
            store.style = UIFontTextStyleBody
            store.trait = UIFontDescriptorSymbolicTraits.TraitItalic
            quoteButton.tintColor = UIColor(red: 25.0/255.0, green: 163.0/255.0, blue: 68.0/255.0, alpha: 1)
            fontButton.tintColor = UIColor.darkGrayColor()
        } else {
            store.style = UIFontTextStyleBody
            store.indent = 0.0
            store.trait = nil
            quoteButton.tintColor = UIColor.darkGrayColor()
        }
        forceRedraw()
    }
    
    @IBAction func insertImage(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as! UIImage
        image = UIImage(CGImage: image.CGImage, scale: image.size.width / (textView.bounds.width - 10), orientation: image.imageOrientation)!
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        
        let newString = NSMutableAttributedString(attributedString: textView.attributedText)
        newString.appendAttributedString(NSAttributedString(string: "\n"))
        newString.insertAttributedString(NSAttributedString(attachment: textAttachment), atIndex: textView.offsetFromPosition(textView.beginningOfDocument, toPosition: textView.selectedTextRange!.end))
        newString.appendAttributedString(NSAttributedString(string: "\n"))
        textView.attributedText = newString
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        textView.resignFirstResponder()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func insertLink(sender: AnyObject) {
        self.textView.resignFirstResponder()
        let alertView = UIAlertView(title: "", message: "Insert link address", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Insert")
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alertView.textFieldAtIndex(0)?.placeholder = "http://"
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if(buttonIndex == 0) {
            return
        }
        
        if(buttonIndex == 1) {
            let text = alertView.textFieldAtIndex(0)!.text
            var url = NSURL(string: text)
            if(url?.scheme == nil) {
               url = NSURL(string: "http://" + text)
            }
            if(url != nil && url!.host != nil && url!.scheme != nil) {
                if(textView.selectedRange.length == 0) {
                    let _string = NSAttributedString(string: url!.absoluteString!, attributes: NSDictionary(object: url!.absoluteString!, forKey: NSLinkAttributeName) as [NSObject : AnyObject])
                    textStorage.insertAttributedString(_string, atIndex: textView.selectedRange.location)
                } else {
                    let _string = NSAttributedString(string: textView.textInRange(textView.selectedTextRange!), attributes: NSDictionary(object: url!.absoluteString!, forKey: NSLinkAttributeName) as [NSObject : AnyObject])
                    textStorage.replaceCharactersInRange(textView.selectedRange, withAttributedString: _string)
                }
            } else {
                UIAlertView(title: "Invalid URL", message: "The URL specified is not valid", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        delegate?.cancel(textView.attributedText)
    }

    @IBAction func publish(sender: AnyObject) {
        delegate?.publish(textView.attributedText)
    }
    
}

