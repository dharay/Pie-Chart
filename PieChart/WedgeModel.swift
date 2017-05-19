//
//  WedgeModel.swift
//  PieChart
//
//  Created by Dharay Mistry on 5/17/17.
//  Copyright © 2017 Dharay Mistry. All rights reserved.
//

import Foundation

public struct Wedge {
    public var title = ""
    public var weight = 1
    public var backgroundColor = UIColor.white
    
    public init(title :String,weight : Int, backgroundColor : UIColor = .white) {
        self.title = title
        self.weight = weight
        self.backgroundColor = backgroundColor
    }
}
