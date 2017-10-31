//
//  GameViewController.swift
//  BattleShip
//
//  Created by Nicholas Fung on 2017-10-31.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var shipView: UICollectionView!
    @IBOutlet weak var gridView: UICollectionView!
    var gridLayout:GridViewLayout = GridViewLayout()
    var shipLayout:GridViewLayout = GridViewLayout()
    var placeShips:Array<Int> = [0,0,0,0,0]
    var gameBoard:GameBoard = GameBoard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.yellow
        // Do any additional setup after loading the view.
        gridView.allowsMultipleSelection = false
        
        self.gridLayout.itemSize = CGSize.init(width: (self.view.frame.size.width-11.0)/10.0, height: (self.view.frame.size.width-11.0)/10.0)
        self.shipLayout.itemSize = CGSize.init(width: (self.view.frame.size.width-11.0)/10.0, height: (self.view.frame.size.width-11.0)/10.0)
        
        gridView.collectionViewLayout = gridLayout
        shipView.collectionViewLayout = shipLayout
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case gridView:
            return 100
            break
        default:
            return 20
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // cells for the ship view
        if collectionView == self.shipView{
            var cell:GridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "shipCell", for: indexPath) as! GridCell
            switch indexPath.row{
            case 5,13,17:
                cell.backgroundColor = UIColor.clear
                break
            default:
                cell.backgroundColor = UIColor.lightGray
                break
            }
            return cell
        }
        
        //cells for the grid view
        
        var cell:GridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! GridCell
        if self.gameBoard.status(forSquare: indexPath.row)?.hasShip == true {
            cell.backgroundColor = UIColor.orange
        }
        
        else {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case gridView:
            collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.red
            self.placeShip(square: indexPath.row)
            break
        case shipView:
            selectShip(square: indexPath.row, isSelected:true)
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case gridView:
            collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.white
            break
        case shipView:
            selectShip(square: indexPath.row, isSelected:false)
            break
        default:
            break
        }
    }
    
    func placeShip(square:Int) {
        var shipLength:Int = 0
        for ship:Int in 0...4 {
            if self.placeShips[ship] == 1 {
                switch ship {
                case 0:
                    shipLength = 5
                    break
                case 1:
                    shipLength = 4
                    break
                case 2, 3:
                    shipLength = 3
                    break
                case 4:
                    shipLength = 2
                    break
                default:
                    break
                }
                
                for i:Int in square...shipLength+square-1 {
                    self.gameBoard.addShip(atSquare: i)
                    self.gridView.cellForItem(at: IndexPath.init(row: i, section: 0))?.backgroundColor = UIColor.orange
                }
                self.placeShips[ship] = 2
                break
            }
        }
        self.gridView.reloadData()
    }
    
    
    
    
    
    
    
    func selectShip(square:Int,isSelected:Bool) -> Void {
        var shipSquares:Array<Int> = []
        switch square{
        case 0,1,2,3,4:
            if self.placeShips[0] != 2 {
                shipSquares = [0,1,2,3,4]
                if isSelected {
                    self.placeShips[0] = 1
                }
                else {
                    self.placeShips[0] = 0
                }
            }
            break
        case 6,7,8,9:
            if self.placeShips[1] != 2 {
                shipSquares = [6,7,8,9]
                if isSelected {
                    self.placeShips[1] = 1
                }
                else {
                    self.placeShips[1] = 0
                }
            }
            break
        case 10,11,12:
            if self.placeShips[2] != 2 {
                shipSquares = [10,11,12]
                if isSelected {
                    self.placeShips[2] = 1
                }
                else {
                    self.placeShips[2] = 0
                }
            }
            break
        case 14,15,16:
            if self.placeShips[3] != 2 {
                shipSquares = [14,15,16]
                if isSelected {
                    self.placeShips[3] = 1
                }
                else {
                    self.placeShips[3] = 0
                }
            }
            break
        case 18,19:
            if self.placeShips[4] != 2 {
                shipSquares = [18,19]
                if isSelected {
                    self.placeShips[4] = 1
                }
                else {
                    self.placeShips[4] = 0
                }
            }
            break
        default:
            shipSquares = []
            break
        }
        for selectedSquares:Int in shipSquares{
            if isSelected {
                shipView.cellForItem(at: IndexPath.init(row: selectedSquares, section: 0))?.backgroundColor = UIColor.red
            } else {
                shipView.cellForItem(at: IndexPath.init(row: selectedSquares, section: 0))?.backgroundColor = UIColor.lightGray
            }
        }
        
    }
}
