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
    
    @IBOutlet weak var buttonOutlet: UIButton!
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
                var shipLocations:Array<Int> = []
                var shipNumbers:Array<Int> = []
                var shipSections:Array<Int> = []
                for allOfTheShips:Int in 0...99{
                    if self.gameBoard.status(forSquare: allOfTheShips)!.hasShip{
                        shipLocations.append(allOfTheShips)
                        shipSections.append(self.gameBoard.status(forSquare: allOfTheShips)!.section)
                        shipNumbers.append(self.gameBoard.status(forSquare: allOfTheShips)!.ship)
                    }
                }
                var shipLocationsNumbersAndSections:Array<Array<Int>> = []
                shipLocationsNumbersAndSections.append(shipLocations)
                shipLocationsNumbersAndSections.append(shipNumbers)
                shipLocationsNumbersAndSections.append(shipSections)
                sendMessage(message: shipLocationsNumbersAndSections)
                if receivedGameBoard{
                    gameState = gameStateEnum.playerTurn
                    self.buttonOutlet.backgroundColor = UIColor.green
                } else {
                    gameState = gameStateEnum.opponentTurn
                    self.buttonOutlet.backgroundColor = UIColor.red
                }
                self.gridView.reloadData()
                self.shipView.reloadData()
                self.buttonOutlet.setTitle("Fire", for: UIControlState.normal)
            } else {
                self.buttonOutlet.setTitle("Must place all ships first", for: UIControlState.normal)
            }
        } else if gameState == gameStateEnum.playerTurn{
            
            //shoot
            if !opponentGameBoard.status(forSquare: fireAtSquare)!.firedOn{
                sendMessage(message: fireAtSquare)
                opponentGameBoard.fireAt(square: fireAtSquare)
                gameState = gameStateEnum.opponentTurn
                self.buttonOutlet.backgroundColor = UIColor.red
                self.gridView.reloadData()
                self.winCheck()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gridView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "gridCell")
        self.shipView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "gridCell")
        
        // Do any additional setup after loading the view.
        gridView.allowsMultipleSelection = false
        
        self.gridLayout.itemSize = CGSize.init(width: (self.view.frame.size.width-11.0)/10.0, height: (self.view.frame.size.width-11.0)/10.0)
        self.shipLayout.itemSize = CGSize.init(width: (self.view.frame.size.width-11.0)/10.0, height: (self.view.frame.size.width-11.0)/10.0)
        
        gridView.collectionViewLayout = gridLayout
        shipView.collectionViewLayout = shipLayout
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleReceivedDataWithNotification(notification:)), name:NSNotification.Name("MPC_DidReceiveDataNotification"), object: nil)
        
        //        for num:Int in 0...19{
        //            shipView.cellForItem(at: IndexPath.init(row: num, section: 0))?.alpha = 0.50
        //        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.selectShip(square:0,isSelected:false)
        self.selectShip(square:6,isSelected:false)
        self.selectShip(square:10,isSelected:false)
        self.selectShip(square:14,isSelected:false)
        self.selectShip(square:18,isSelected:false)
    }
    
    @objc func handleReceivedDataWithNotification(notification:Notification){
        let userInfo = notification.userInfo! as Dictionary
        let recievedData:Data = userInfo["data"] as! Data
        let messageDict = try! JSONSerialization.jsonObject(with: recievedData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        let message:Any = messageDict.object(forKey: "message")!
        if message is Array<Array<Int>>{
            var board:Array<Array<Int>> = message as! Array<Array<Int>>

            receivedGameBoard = true
            for i:Int in 0..<board[0].count {
                self.opponentGameBoard.addShip(atSquare: board[0][i], shipNumber: board[1][i], shipSection: board[2][i])
            }
        }
        if message is Int{
            let numFire:Int = message as! Int
            gameBoard.fireAt(square: numFire)
            self.shipView.reloadData()
            gameState = gameStateEnum.playerTurn
            self.buttonOutlet.backgroundColor = UIColor.green
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
            
            alert.addAction(UIAlertAction(title: "Leave Game", style: UIAlertActionStyle.default, handler: { _ in self.endGame()}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func endGame(){
        self.dismiss(animated: true, completion: nil)
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
    
    func getShipAndSection(num:Int) -> (ship:Int, section:Int){
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // cells for the ship view
        if collectionView == self.shipView{
            let cell:GridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as! GridCell
            switch indexPath.row{
            case 5,13,17:
                cell.backgroundColor = UIColor.clear
                cell.cellImageView.image = nil
                break
            default:
                let shipAndSection = self.getShipAndSection(num: indexPath.row)
                if gameBoard.shipSectionStatus(shipNumber: shipAndSection.ship, shipSection: shipAndSection.section){
                    //ship section has been hit
                    
                    let shipImage:UIImage = self.imageForShipSection(ship: shipAndSection.ship, shipSection: shipAndSection.section, isHit: true)
                    
                    cell.cellImageView.image = shipImage
                    
                } else {
                    //ship section has not been hit
                    
                    
                    let shipImage:UIImage = self.imageForShipSection(ship: shipAndSection.ship, shipSection: shipAndSection.section, isHit: false)
                    
                    cell.cellImageView.image = shipImage
                }
                break
            }
            return cell
        }
        
        //cells for the grid view
        
        let cell:GridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as! GridCell
        
        if gameState != gameStateEnum.placement{ //during gameplay
            
            cell.cellImageView.image = nil
            if self.opponentGameBoard.status(forSquare: indexPath.row)!.hasShip {
                if self.opponentGameBoard.status(forSquare: indexPath.row)!.firedOn{
                    //hit ship
                    let shipNumber = self.opponentGameBoard.status(forSquare: indexPath.row)?.ship
                    let sectionNumber = self.opponentGameBoard.status(forSquare: indexPath.row)?.section
                    
                    let shipImage:UIImage = self.imageForShipSection(ship: shipNumber!, shipSection: sectionNumber!, isHit: false)
                    
                    cell.cellImageView.image = shipImage
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
        } else { //during placement
            if self.gameBoard.status(forSquare: indexPath.row)?.hasShip == true {
                let ship:Square = self.gameBoard.status(forSquare: indexPath.row)!
                let shipImage:UIImage = self.imageForShipSection(ship: ship.ship, shipSection: ship.section, isHit: false)
                cell.cellImageView.image = shipImage
                cell.backgroundColor = UIColor.orange
            }
                
            else {
                cell.cellImageView.image = nil
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
                    self.gameBoard.addShip(atSquare: i, shipNumber: ship, shipSection: i - square)
                    
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
                shipView.cellForItem(at: IndexPath.init(row: selectedSquares, section: 0))?.alpha = 1.0
            } else {
                shipView.cellForItem(at: IndexPath.init(row: selectedSquares, section: 0))?.alpha = 0.50
            }
        }
        
    }
    
    func imageForShipSection(ship:Int, shipSection:Int, isHit:Bool) -> UIImage {
        var imageFilename:String = ""
        if shipSection == 0 {
            imageFilename = "VShipBack"
        }
        else if ship == 0 && shipSection == 4 ||
            ship == 1 && shipSection == 3 ||
            ship == 2 && shipSection == 2 ||
            ship == 3 && shipSection == 2 ||
            ship == 4 && shipSection == 1 {
            imageFilename = "VShipFront"
        }
        else {
            imageFilename = "VShipMiddle"
        }
        
        if isHit {
            imageFilename.append("Hit")
        }
        
        return UIImage(named: imageFilename)!
    }
    
    
    
}
