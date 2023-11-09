//
//  ArticleTable+CoreDataProperties.swift
//  
//
//  Created by bjit on 16/1/23.
//
//

import Foundation
import CoreData


extension ArticleTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleTable> {
        return NSFetchRequest<ArticleTable>(entityName: "ArticleTable")
    }

    @NSManaged public var author: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var newsDescription: String?
    @NSManaged public var content: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?

}
