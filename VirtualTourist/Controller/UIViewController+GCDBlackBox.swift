//
//  UIViewController+GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Hiren Samtani on 03/06/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
}
