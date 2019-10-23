//
//  PersistenceService.swift
//  TestWorkForEvo
//
//  Created by Dima Senchik on 4/22/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import CoreData

class PersistenceService {
    
    private init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
		let modelURL = Bundle(for: DecryptionViewController.self).url(forResource: "RecentAdModel", withExtension:"momd")
		if let objectModel = NSManagedObjectModel(contentsOf: modelURL!) {
			let container = NSPersistentContainer(name: "RecentAdModel", managedObjectModel: objectModel)
			container.loadPersistentStores(completionHandler: { (storeDescription, error) in
				if let error = error as NSError? {
					fatalError("Unresolved error \(error), \(error.userInfo)")
				}
			})
			return container
		}
		
		return NSPersistentContainer()
    }()
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
