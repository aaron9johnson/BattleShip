//
//  gameBoard.swift
//  battleship logic
//
//  Created by Nicholas Fung on 2017-10-30.
//  Copyright © 2017 Nicholas Fung. All rights reserved.
//

import UIKit

class GameBoard: NSObject {
    
    var boardArr = Array<Square>(repeating: Square(), count: 100)
    var shipArr = Array<ShipClass>()
    @objc dynamic var numHits: Int = 0
    
    
    func fireAt(square: Int) {
        if validate(square: square) {
            if self.boardArr[square].firedOn == false && self.boardArr[square].hasShip == true {
                self.numHits += 1
            }
            self.boardArr[square].firedOn = true
        }
    }
    
    func status(forSquare: Int) -> Square? {
        if validate(square: forSquare) {
            return self.boardArr[forSquare]
        }
        else {
            return nil
        }
    }
    func shipSectionStatus(shipNumber: Int, shipSection: Int) -> Bool{
        for square:Square in boardArr{
            if square.ship == shipNumber && square.section == shipSection{
                return square.firedOn
            }
        }
        return false
    }
    
    func addShip(atSquare: Int, shipNumber: Int, shipSection: Int, shipRotation: Bool) {
        if validate(square: atSquare) {
            self.boardArr[atSquare].hasShip = true
            self.boardArr[atSquare].ship = shipNumber
            self.boardArr[atSquare].section = shipSection
            self.boardArr[atSquare].isVertical = shipRotation
        }
    }
    
    func validate(square: Int) -> Bool {
        return square >= 0 && square < 100
    }
}
