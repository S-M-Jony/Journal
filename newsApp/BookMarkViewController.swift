//
//  BookMarkViewController.swift
//  newsApp
//
//  Created by bjit on 16/1/23.
//

import UIKit
import CoreData
import SDWebImage

class BookMarkViewController: UIViewController {
    
    @IBOutlet weak var bookmarkTableView: UITableView!
    @IBOutlet weak var bookMarkSearchBar: UITextField!
    @IBOutlet weak var bookmarkGifImage: UIImageView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var secondTableArray = [BookMarkTable]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        secondTableArray = loadAllCoreData()!
        //topViewBV.layer.cornerRadius = 20
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
    
        // bookMark searchbar
        bookMarkSearchBar.clearButtonMode = .whileEditing
        bookMarkSearchBar.delegate = self
        
        // bookmark gif
       // let gif = UIImage.gifImageWithName("bookmark-4")
        let gif = UIImage(named: "bookmark-4")
        bookmarkGifImage.image = gif
       
    }
    override func viewWillAppear(_ animated: Bool) {
        secondTableArray = loadAllCoreData()!
        bookmarkTableView.reloadData()
    }
    
    @IBAction func bookMarkSearchButton(_ sender: Any) {
        let queryText  = bookMarkSearchBar.text!
        searchedItem(queryText)
    }
    func loadAllCoreData() -> [BookMarkTable]?{
        var arrayList = [BookMarkTable]()
        let request : NSFetchRequest<BookMarkTable> = BookMarkTable.fetchRequest()
        
        do{
            arrayList = try context.fetch(request)
          }catch {
                print("Error\(error)")
            }
                
        return arrayList
    }
    func saveItems(){
        do{
            try context.save() // save the state
  
        }catch{
            print("error")
        }
    }
}

extension BookMarkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        secondTableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bookmarkTableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as! BookMarkTableViewCell
        cell.bookmarkTitle.text = secondTableArray[indexPath.row].title
        let imageURL = URL(string: secondTableArray[indexPath.row].urlToImage ?? "https://placeimg.com/220/220/any")
        cell.bookmarkImage.sd_setImage(with: imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
    // swipe action
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil){  [weak self] _,_,completion in
            guard let self = self else {
                return
            }
            self.handledeleteAction(indexPath: indexPath)
            completion(true)
        }

        deleteAction.image = UIImage(systemName: "trash.square.fill")
        deleteAction.backgroundColor = UIColor(hex: 0xDD5353)
        
        let swipAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipAction.performsFirstActionWithFullSwipe = false
        return swipAction
        
    }
    
    func handledeleteAction(indexPath: IndexPath){
        print(indexPath.row)
        context.delete(secondTableArray[indexPath.row])
        secondTableArray.remove(at: indexPath.row)
        bookmarkTableView.reloadSections([0], with: .fade)
        saveItems()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "wayToWebView", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = bookmarkTableView.indexPathForSelectedRow
        
        if let destinationVC = segue.destination as? WebViewController {
            destinationVC.destinationUrl = secondTableArray[index!.row].url
        }
    }
}
// search functionality
extension BookMarkViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let queryText  = bookMarkSearchBar.text!
        searchedItem(queryText)
    }

    func searchedItem(_ query : String){
        if query.count == 0 {
            return
        }
        let newsSearchPredicate = NSPredicate(format: "title BEGINSWITH[c] %@",query)
        let request : NSFetchRequest<BookMarkTable> = BookMarkTable.fetchRequest()
        request.predicate = newsSearchPredicate
        var matchedResultArray = [BookMarkTable]()
        do{
            matchedResultArray = try context.fetch(request)
        }catch {
            print("Error\(error)")
        }
        secondTableArray = matchedResultArray
        bookmarkTableView.reloadData()
    }
}


