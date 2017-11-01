//
//  GameViewController.swift
//  BattleShip
//
//  Created by Nicholas Fung on 2017-10-31.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

import UIKit
import MultipeerConnectivity
enum gameStateEnum{
    case placement, playerTurn, opponentTurn, gameOver
}

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var shipView: UICollectionView!
    @IBOutlet weak var gridView: UICollectionView!
    var gridLayout:GridViewLayout = GridViewLayout()
    var shipLayout:GridViewLayout = GridViewLayout()
    var placeShips:Array<Int> = [0,0,0,0,0]
    var gameBoard:GameBoard = GameBoard()
    var opponentGameBoard:GameBoard = GameBoard()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var gameState:gameStateEnum = gameStateEnum.placement
    var receivedGameBoard = false
    var fireAtSquare = 0
    
    @IBAction func Shoot(_ sender: Any) {
        if gameState == gameStateEnum.placement{
            var flag:Bool = true
            for ship:Int in self.placeShips{
                if ship != 2{
                    flag = false
                }
            }
            if flag{
                var ships:Array<Int> = []
                for allOfTheShips:Int in 0...99{
                    if self.gameBoard.status(forSquare: allOfTheShips)!.hasShip{
                        ships.append(allOfTheShips)
                    }
                }
                sendMessage(message: ships)
                if receivedGameBoard{
                    gameState = gameStateEnum.playerTurn
                } else {
                    gameState = gameStateEnum.opponentTurn
                }
            }
        }
        if gameState == gameStateEnum.playerTurn{
            
            //shoot
            if !opponentGameBoard.status(forSquare: fireAtSquare)!.firedOn{
                sendMessage(message: fireAtSquare)
                opponentGameBoard.fireAt(square: fireAtSquare)
                gameState = gameStateEnum.opponentTurn
                self.gridView.reloadData()
                self.winCheck()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gridView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "gridCell")
        self.shipView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "gridCell")

        self.view.backgroundColor = UIColor.yellow
        // Do any additional setup after loading the view.
        gridView.allowsMultipleSelection = false
        
        self.gridLayout.itemSize = CGSize.init(width: (self.view.frame.size.width-11.0)/10.0, height: (self.view.frame.size.width-11.0)/10.0)
        self.shipLayout.itemSize = CGSize.init(width: (self.view.frame.size.width-11.0)/10.0, height: (self.view.frame.size.width-11.0)/10.0)
        
        gridView.collectionViewLayout = gridLayout
        shipView.collectionViewLayout = shipLayout
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleReceivedDataWithNotification(notification:)), name:NSNotification.Name("MPC_DidReceiveDataNotification"), object: nil)
        
    }
    @objc func handleReceivedDataWithNotification(notification:Notification){
        let userInfo = notification.userInfo! as Dictionary
        let recievedData:Data = userInfo["data"] as! Data
        let messageDict = try! JSONSerialization.jsonObject(with: recievedData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        let message:Any = messageDict.object(forKey: "message")!
        if message is Array<Int>{
            var board:Array<Int> = message as! Array<Int>
            receivedGameBoard = true
            for anything:Int in board {
                self.opponentGameBoard.addShip(atSquare: anything)
            }
        }
        if message is Int{
            var numFire:Int = message as! Int
            gameBoard.fireAt(square: numFire)
            gameState = gameStateEnum.playerTurn
            self.winCheck()
            //oponent shot at
        }
    }
    func winCheck(){
        var playerWins:Bool = true
        var opponentWins:Bool = true
        for num:Int in 0...99{
            if self.gameBoard.status(forSquare: num)!.hasShip{
                if !self.gameBoard.status(forSquare: num)!.firedOn{
                    opponentWins = false
                }
            }
        }
        for num:Int in 0...99{
            if self.opponentGameBoard.status(forSquare: num)!.hasShip{
                if !self.opponentGameBoard.status(forSquare: num)!.firedOn{
                    playerWins = false
                }
            }
        }
        if playerWins || opponentWins{
            gameState = gameStateEnum.gameOver
            var alert:UIAlertController
            if playerWins{
                alert = UIAlertController(title: "GAMEOVER", message: "You Win!", preferredStyle: UIAlertControllerStyle.alert)
            } else {
                alert = UIAlertController(title: "GAMEOVER", message: "You Loose :(", preferredStyle: UIAlertControllerStyle.alert)
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func sendMessage(message: Any){
        let messageDict = ["message":message, "player":UIDevice.current.name] as [String : Any]
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        try! appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
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
        
        // cells for the ship view
        if collectionView == self.shipView{
            var cell:GridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as! GridCell
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
        var cell:GridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as! GridCell
        cell.cellImageView.image = nil
        if self.opponentGameBoard.status(forSquare: indexPath.row)!.hasShip{
            if self.opponentGameBoard.status(forSquare: indexPath.row)!.firedOn{
                //hit ship
                cell.backgroundColor = UIColor.black
            } else {
                //unHit Opponent Ship
                cell.backgroundColor = UIColor.white
            }
        } else {
            if self.opponentGameBoard.status(forSquare: indexPath.row)!.firedOn{
                //missed shot
                cell.backgroundColor = UIColor.lightGray
            } else {
                //normal square
                cell.backgroundColor = UIColor.white
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case gridView:

            if gameState == gameStateEnum.placement{
                self.placeShip(square: indexPath.row)
            }
            if gameState == gameStateEnum.playerTurn{
                let cell:GridCell = collectionView.cellForItem(at: indexPath) as! GridCell
                let myImage:UIImage = UIImage(named:"target")!
                cell.cellImageView.image = myImage
                fireAtSquare = indexPath.row
            }
            
            break
        case shipView:
            if gameState == gameStateEnum.placement{
                selectShip(square: indexPath.row, isSelected:true)
            }
            
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case gridView:
            let cell:GridCell = collectionView.cellForItem(at: indexPath) as! GridCell
            cell.cellImageView.image = nil
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
                self.gridView.reloadData()
                break
            }
        }
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
