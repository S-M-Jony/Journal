//
//  NewsTableViewCell.swift
//  newsApp
//
//  Created by bjit on 13/1/23.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var postTime: UILabel!
    var passedArticle = ArticleTable()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
