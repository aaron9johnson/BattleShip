//
//  Square.swift
//  battleship logic
//
//  Created by Nicholas Fung on 2017-10-30.
//  Copyright © 2017 Nicholas Fung. All rights reserved.
//

import UIKit

enum ShipOrientation {
    case vertical, horizontal
}

struct Square {
    var hasShip: Bool = false
    var firedOn: Bool = false
    var ship:Int = -1
    var section:Int = -1
    var isVertical:Bool = false
}
