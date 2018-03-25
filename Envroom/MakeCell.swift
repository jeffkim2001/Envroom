//
//  MakeCell.swift
//  Envroom
//
//  Created by Jeff Kim on 3/25/18.
//  Copyright © 2018 Jeff Kim. All rights reserved.
//

import UIKit

class MakeCell: UITableViewCell {

    @IBOutlet weak var makeNameLabel: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundCardView.layer.backgroundColor = UIColor.white.cgColor
        contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        backgroundCardView.layer.cornerRadius = 10.0
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
