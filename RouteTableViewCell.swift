//
//  RouteTableViewCell.swift
//  TransitAlarm
//
//  Created by id on 5/2/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel?.font = UIFont(name: "Helvetica-Bold", size: 20)
        idLabel?.font = UIFont(name: "Helvetica-Bold", size: 20)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
