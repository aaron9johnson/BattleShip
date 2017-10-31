//
//  ViewController.swift
//  BattleShip
//
//  Created by Aaron Johnson on 2017-10-30.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate {
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(advertise: true)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.peerChangedStateWithNotification(notification:)), name:NSNotification.Name("MPC_DidChangeStateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleReceivedDataWithNotification(notification:)), name:NSNotification.Name("MPC_DidReceiveDataNotification"), object: nil)
    }
    
    @IBAction func Connect(_ sender: Any) {
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.present(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    @IBAction func Button(_ sender: Any) {
        self.sendMessage(square: [1])
    }
    func sendMessage(square: Array<Int>){
        let messageDict = ["square":square, "player":UIDevice.current.name] as [String : Any]
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        try! appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
    }
    
    @objc func peerChangedStateWithNotification(notification:Notification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.object(forKey: "state") as! MCSessionState
        if  state.rawValue == MCSessionState.connected.rawValue{
            self.navigationItem.title = "Connected"
        }
    }
    
    @objc func handleReceivedDataWithNotification(notification:Notification){
        let userInfo = notification.userInfo! as Dictionary
        let recievedData:Data = userInfo["data"] as! Data
        let message = try! JSONSerialization.jsonObject(with: recievedData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        let square:Array = message.object(forKey: "square") as! Array<Int>
        if square.count == 1{
            //opponent fired at square: square[0]
        } else {
            //board set up with opponent ships at positions: square[]
        }
        
        let alert = UIAlertController(title: "Alert", message: "Sender: " + senderDisplayName, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
}

