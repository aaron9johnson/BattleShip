//
//  BasicHelper.swift
//  BattleShip
//
//  Created by Nicholas Fung on 2017-11-01.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

import UIKit

class BasicHelper: NSObject {

    class func getImageFor(ship:Int, section:Int, orientation:ShipOrientation, isHit:Bool) -> UIImage {
        
        var imageFilename:String = ""
        
        if orientation == ShipOrientation.horizontal {
            imageFilename = "H"
        }
        else if orientation == ShipOrientation.vertical {
            imageFilename = "V"
        }
        
        if section == 0 {
            imageFilename.append("ShipBack")
        }
        else if ship == 0 && section == 4 ||
            ship == 1 && section == 3 ||
            ship == 2 && section == 2 ||
            ship == 3 && section == 2 ||
            ship == 4 && section == 1 {
            imageFilename.append("ShipFront")
        }
        else {
            imageFilename.append("ShipMiddle")
        }
        
        if isHit {
            imageFilename.append("Hit")
        }
        
        return UIImage(named: imageFilename)!
    }
    
    class func getShipAndSection(num:Int) -> (ship:Int, section:Int){
        switch num{
        case 0:
            return (0,0)
        case 1:
            return (0,1)
        case 2:
            return (0,2)
        case 3:
            return (0,3)
        case 4:
            return (0,4)
        case 6:
            return (1,0)
        case 7:
            return (1,1)
        case 8:
            return (1,2)
        case 9:
            return (1,3)
        case 10:
            return (2,0)
        case 11:
            return (2,1)
        case 12:
            return (2,2)
        case 14:
            return (3,0)
        case 15:
            return (3,1)
        case 16:
            return (3,2)
        case 18:
            return (4,0)
        case 19:
            return (4,1)
        default:
            return (0,0)
        }
    }
    
    
    
    
}
