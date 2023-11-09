//
//  ViewController.swift
//  newsApp
//
//  Created by bjit on 12/1/23.
//

import UIKit
import CoreData
import SDWebImage

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var gifImage: UIImageView!
    
    var categoryData = ["All","Business","Entertainment","General","Health","Science","Sports","Technology"]
    var selectedIndex = 0
    var isSelectCategory = false
    var newsData = [Article]()
    var refreshControl = UIRefreshControl()
    var loaderArray: [Article] = []
    var tableArray = [ArticleTable]()
    var tempoaryArticleArray = [ArticleTable]()
    var bookmarkArticles = [BookMarkTable]()
    var currentCategory = "all"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var myTimer = Timer()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForUpdateData()
        myTimer = Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(actionUpdate), userInfo: nil, repeats: true)
        loadArrayByCategories(categoryType: currentCategory)
        
        // collection-view
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 50)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        // table-view
        tableView.dataSource = self
        tableView.delegate = self
    
        // loading data
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        //fetchAllCategoryToCoreData()
        
        // searchbar
        searchBar.clearButtonMode = .whileEditing
        searchBar.delegate = self
        
        // gif
      //  let gif = UIImage.gifImageWithName("reader")
      // gifImage.image = gif
    }
    
    @objc func actionUpdate(){
        checkForUpdateData()
    }
    
    func checkForUpdateData(){
        
        let currentTime = Date()
        if let lastUpdate = (defaults.object(forKey: "lastUpdateTime") as? Date){
            let timeInterval = currentTime.timeIntervalSince(lastUpdate)
            
            if timeInterval > 18000{
                refreshCoreData()
                defaults.set (Date(), forKey: "lastUpdateTime")
            }else{
                
                return
            }
        }else{
            fetchAllCategoryToCoreData()
            self.defaults.set (Date(), forKey: "lastUpdateTime")
        }
    }
    
    @objc func refresh(send: UIRefreshControl){
        refreshCoreData()
        refreshControl.endRefreshing ()
    }
    
    
    @IBAction func newsSearchButton(_ sender: Any) {
        let queryText  = searchBar.text!
        searchedItem(queryText)
    }
    

    // save items functionality
    
    func saveItems(){
        do{
            try context.save() // save the state
  
        }catch{
            print("error")
        }
    }
    // fetch all category to core data
    
    func fetchAllCategoryToCoreData(){
        for i in 0..<categoryData.count {
            getDatatoCoreData(categoryType: categoryData[i])
        }
    }
    
    // get data from core data
    
    func getDatatoCoreData(categoryType : String){
    
        var apiLink = ("https://newsapi.org/v2/top-headlines?country=us&category=\(categoryType.lowercased())&apiKey=a6d263dbc7f6407f997249d017d07099&pageSize=25")

        if(categoryType == "All"){
            apiLink = ("https://newsapi.org/v2/top-headlines?country=us&apiKey=a6d263dbc7f6407f997249d017d07099&pageSize=25")
        }
        let url = URL(string: apiLink)!

        getNewsInfo(url: url) { [self] result in
            switch result{
            case .success(let response):
                loaderArray = response
                for i in 0..<loaderArray.count{
                    let temp = ArticleTable(context: self.context)
                    temp.author = loaderArray[i].author
                    temp.content = loaderArray[i].content
                    temp.newsDescription = loaderArray[i].description
                    temp.publishedAt = loaderArray[i].publishedAt
                    temp.title = loaderArray[i].title
                    temp.url = loaderArray[i].url
                    temp.urlToImage = loaderArray[i].urlToImage
                    temp.categoryName = categoryType.lowercased()
                    self.tempoaryArticleArray.append(temp)
                    
                }
                saveItems()
                
                DispatchQueue.main.async { [self] in
                    loadArrayByCategories(categoryType: currentCategory)
                }
                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
        loadArrayByCategories(categoryType: currentCategory)
    }
    
    // get news data
    func getNewsInfo(url: URL?, completion: @escaping (Result<[Article], Error>) -> Void) {

        guard let url = url else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(Welcome.self, from: data)
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // load array by categories
    
    func loadArrayByCategories(categoryType : String = "all"){
        tableArray = searchCatergory(categoryType: categoryType)!
        print(tableArray.count)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // fetching data by search category
    
    func searchCatergory(categoryType: String) -> [ArticleTable]?{
        let SearchPredicate = NSPredicate(format: "categoryName MATCHES %@", categoryType)
        let request : NSFetchRequest<ArticleTable> = ArticleTable.fetchRequest()
        request.predicate = SearchPredicate
        var matchedSearchedCategoryArray = [ArticleTable]()
        do{
          matchedSearchedCategoryArray = try context.fetch(request)

        }catch {
            print("Error\(error)")
        }
        return matchedSearchedCategoryArray
    }

    // load everything to core data
    func loadEverythingCD() -> [ArticleTable]?{
         var arrayList = [ArticleTable]()
         let request : NSFetchRequest<ArticleTable> = ArticleTable.fetchRequest()
            do{
                 arrayList = try context.fetch(request)
             }catch {
                    print("Error\(error)")
                }
        return arrayList
    }
    // erase everything to current core data
    func eraseEverythingFromCoreData(){
        tempoaryArticleArray = loadEverythingCD()!
        
        if tempoaryArticleArray.count == 0 {
            return
        }
        for i in 0..<tempoaryArticleArray.count{
            context.delete(tempoaryArticleArray[i])
        }
        saveItems()
    }
    // refresh core data
    func refreshCoreData(){
        eraseEverythingFromCoreData()
        fetchAllCategoryToCoreData()
    }
}

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        cell.categoryType.text = categoryData[indexPath.row]
        cell.layer.cornerRadius = 20
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        currentCategory = categoryData[indexPath.row].lowercased()
        loadArrayByCategories(categoryType: categoryData[indexPath.row].lowercased())
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(hex: 0xCEAB93)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(hex: 0xDBC8AC)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsTableViewCell", for: indexPath) as!
        NewsTableViewCell
        cell.newsTitle.text = tableArray[indexPath.row].title
        let imageURL = URL(string: tableArray[indexPath.row].urlToImage ?? "https://placeimg.com/220/220/any")
        cell.newsImage.sd_setImage(with: imageURL)
        cell.authorName.text = tableArray[indexPath.row].author ?? "Unknown Author Name"
        
        return cell
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 140
//
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "wayToNewsDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = tableView.indexPathForSelectedRow
        
        if let destinationVC = segue.destination as? DetailsNewsViewController {
            destinationVC.delegate = tableArray[index!.row]
        }
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let queryText  = searchBar.text!
        searchedItem(queryText)
    }

    func searchedItem(_ query : String){
        if query.count == 0 {
            return
        }
        let newsSearchPredicate = NSPredicate(format: "categoryName MATCHES %@ && (title BEGINSWITH[c] %@)", currentCategory , query)
        let request : NSFetchRequest<ArticleTable> = ArticleTable.fetchRequest()
        request.predicate = newsSearchPredicate
        var matchedResultArray = [ArticleTable]()
        do{
            matchedResultArray = try context.fetch(request)
        }catch {
            print("Error\(error)")
        }
        tableArray = matchedResultArray
        tableView.reloadData()
    }
}

extension UIColor {
    convenience init(hex: Int) {
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
}




