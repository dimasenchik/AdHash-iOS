//
//  RecentAdModel+CoreDataProperties.swift
//  AdHash-iOS
//
//  Created by Dima Senchik on 10/13/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//
//

import Foundation
import CoreData

extension RecentAdModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentAdModel> {
        return NSFetchRequest<RecentAdModel>(entityName: "RecentAdModel")
    }

    @NSManaged public var viewedTimestamp: Int64
    @NSManaged public var advertiserID: String?
    @NSManaged public var budgetID: Int64
    @NSManaged public var adID: String?

}
