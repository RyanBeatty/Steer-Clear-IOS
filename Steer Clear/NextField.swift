//
//  NextField.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 9/1/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import Foundation
import UIKit

private var kAssociationKeyNextField: UInt8 = 0


extension UITextField {
    @IBOutlet var nextField: UITextField? {
        get {
            return objc_getAssociatedObject(self,     &kAssociationKeyNextField) as? UITextField
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextField,     newField, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}