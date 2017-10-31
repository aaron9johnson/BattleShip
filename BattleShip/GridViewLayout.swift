//
//  GridViewLayout.swift
//  BattleShip
//
//  Created by Nicholas Fung on 2017-10-31.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

import UIKit

class GridViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        minimumLineSpacing = 1.0
        minimumInteritemSpacing = 1.0
        sectionInset = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    
    
    

}
