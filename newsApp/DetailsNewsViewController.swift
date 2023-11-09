//
//  DetailsNewsViewController.swift
//  newsApp
//
//  Created by bjit on 16/1/23.
//

import UIKit
import CoreData
import SDWebImage

class DetailsNewsViewController: UIViewController {

    @IBOutlet weak var newsDetailsTitle: UILabel!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var detailslargeImage: UIImageView!
    @IBOutlet weak var bookMarkButton: UIButton!
    @IBOutlet weak var bookMarkStatus: UILabel!
    
    var delegate = ArticleTable()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsDetailsTitle.text = delegate.title
        newsDescription.text = delegate.newsDescription
        detailslargeImage.layer.cornerRadius = 20
        authorName.text = delegate.author ?? "Unknown Author Name"
        let imageURL = URL(string: delegate.urlToImage ?? "https://placeimg.com/220/220/any")
        detailslargeImage.sd_setImage(with: imageURL)
        let dateString = delegate.publishedAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = dateFormatter.date(from: dateString!) else {
            fatalError("Unable to parse date")
        }
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
        let formattedDate = dateFormatter.string(from: date)
        postTime.text = formattedDate
    }
    @IBAction func bookMarkButton(_ sender: Any) {
        let isAlreadyBookmarked = searchCatergoryBookmark(getUrl: delegate.url!)
            if (isAlreadyBookmarked!.count > 0){
                bookMarkButton.setImage(UIImage(systemName: "bookmark.square.fill"), for: .normal)
                bookMarkStatus.text = "Already BookMarked Before!"
                bookMarkStatus.textColor = UIColor(hex: 0x10A19D)
                return
        }
        let temp = BookMarkTable(context: self.context) 
        temp.author = delegate.author
        temp.content = delegate.content
        temp.newsDescription = delegate.newsDescription
        temp.publishedAt = delegate.publishedAt
        temp.title = delegate.title
        temp.url = delegate.url
        temp.urlToImage = delegate.urlToImage
        temp.categoryName = delegate.categoryName
        saveItems()
        bookMarkButton.setImage(UIImage(systemName: "bookmark.square.fill"), for: .normal)
        bookMarkStatus.text = "BookMarked!"
        bookMarkStatus.textColor = UIColor(hex: 0x10A19D)
    }
    
    func searchCatergoryBookmark(getUrl: String) -> [BookMarkTable]?{
            let searchPredicate = NSPredicate(format: "url MATCHES %@", getUrl)
            let request : NSFetchRequest<BookMarkTable> = BookMarkTable.fetchRequest()
            request.predicate = searchPredicate
            var matchedArray = [BookMarkTable]()
            do{
              matchedArray = try context.fetch(request)
            }catch {
                print("Error\(error)")
            }
            return matchedArray
        }
    func saveItems(){
        do{
            try context.save() 
  
        }catch{
            print("error")
        }
    }
    
    @IBAction func readMoreButton(_ sender: Any) {
        performSegue(withIdentifier: "wayFromDeatilsToWebView", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? WebViewController{
            destinationVC.destinationUrl = delegate.url
    }
  }
}
