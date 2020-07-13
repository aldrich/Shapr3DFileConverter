//
//  DataManager+FetchedResultsControllerDelegate.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/13/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import CoreData

extension ShaprDataManager: NSFetchedResultsControllerDelegate {
	
	var fetchedResultsController: NSFetchedResultsController<Base3DFormat> {
		
		if _fetchedResultsController != nil {
			return _fetchedResultsController!
		}
		
		let fetchRequest: NSFetchRequest<Base3DFormat> =
			Base3DFormat.fetchRequest()
		
		fetchRequest.fetchBatchSize = 20
		
		let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
		
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		let aFetchedResultsController =
			NSFetchedResultsController(fetchRequest: fetchRequest,
									   managedObjectContext: self.managedObjectContext!,
									   sectionNameKeyPath: nil, cacheName: "Master")
		
		aFetchedResultsController.delegate = self
		
		_fetchedResultsController = aFetchedResultsController
		
		do {
			try _fetchedResultsController!.performFetch()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
		
		return _fetchedResultsController!
	}
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.willChange()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any,
					at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType,
					newIndexPath: IndexPath?) {
		switch type {
		case .insert: delegate?.shouldInsertAt([newIndexPath!])
		case .delete: delegate?.shouldDeleteAt([indexPath!])
		default: return
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.didChange()
	}
}
