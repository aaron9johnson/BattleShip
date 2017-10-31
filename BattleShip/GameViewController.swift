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
        default:
            return 20
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        var cell:GridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! GridCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case gridView:
            collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.red
        case shipView:
           selectShip(square: indexPath.row, isSelected:true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case gridView:
            collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.white
        case shipView:
            selectShip(square: indexPath.row, isSelected:false)
        default:
            break
        }
    }
    func selectShip(square:Int,isSelected:Bool) -> Void {
        var shipSquares:Array<Int>
        switch square{
        case 0,1,2,3,4:
            shipSquares = [0,1,2,3,4]
            break
        case 6,7,8,9:
            shipSquares = [6,7,8,9]
            break
        case 10,11,12:
            shipSquares = [10,11,12]
            break
        case 14,15,16:
            shipSquares = [14,15,16]
            break
        case 18,19:
            shipSquares = [18,19]
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
