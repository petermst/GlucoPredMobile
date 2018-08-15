//
//  TimeExVarTableViewCell.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 25/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import UIKit

class TimeExVarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var secondUpperLabel: UILabel!
    
    @IBOutlet weak var secondLowerLabel: UILabel!
    
    @IBOutlet weak var thirdLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
}
