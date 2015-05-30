//
//  MediumEditorViewControllerDelegate.swift
//  MediumEditor
//
//  Created by Matthew Bain on 30/05/2015.
//  Copyright (c) 2015 Codeghost Ltd. All rights reserved.
//

import Foundation

protocol MediumEditorViewControllerDelegate {
    func publish(text: NSAttributedString)
    func cancel(text: NSAttributedString)
}