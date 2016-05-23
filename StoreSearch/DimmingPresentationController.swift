//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Roman Ustiantcev on 20/05/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }

}
