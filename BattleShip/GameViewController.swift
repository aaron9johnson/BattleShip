//
//  GameViewController.swift
//  BattleShip
//
//  Created by Nicholas Fung on 2017-10-31.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:GridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! GridCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.red
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.white

    }


    @IBOutlet weak var gridView: UICollectionView!
    var layout:GridViewLayout = GridViewLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gridView.delegate = self
        gridView.dataSource = self
        gridView.allowsMultipleSelection = false
        
        
        
        self.layout.itemSize = CGSize.init(width: (self.view.frame.size.width-11.0)/10.0, height: (self.view.frame.size.width-11.0)/10.0) 
        
        gridView.collectionViewLayout = layout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
