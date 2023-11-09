//
//  BookMarkTableViewCell.swift
//  newsApp
//
//  Created by bjit on 16/1/23.
//

import UIKit

class BookMarkTableViewCell: UITableViewCell {

    @IBOutlet weak var bookmarkImage: UIImageView!
    @IBOutlet weak var bookmarkTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
