//
//  DataManager.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import CoreData
import Shapr3DFileConverter

extension Base3DFormat: BaseFormat {}

extension Derived3DFormat: DerivedFormat {}

protocol DataManagerDelegate: class {
	
	func willChange()
	
	func didChange()
	
	func shouldRefresh()
	
	func shouldRemove()
	
	func shouldInsertAt(_ indexPaths: [IndexPath])
	
	func shouldDeleteAt(_ indexPaths: [IndexPath])
}

protocol DataManager {
	
	func importFile(filename: String,
					data: Data,
					imageData: Data?,
					thumbnailData: Data?)
	
	func getFileForID(baseFileId id: UUID) -> Base3DFormat?
	
	func updateConvertProgress(file: Base3DFormat,
							   targetFormat format: ShaprOutputFormat,
							   progress: Float,
							   created: Date?,
							   data: Data?)
	
	func objectAtIndex(_ index: Int) -> Base3DFormat
	
	func count() -> Int
	
	func deleteAtIndex(_ index: Int)
}

class ShaprDataManager: NSObject, DataManager {
	
	weak var delegate: DataManagerDelegate?
	
	// same moc used by `_fetchedResultsController`
	var managedObjectContext: NSManagedObjectContext
	
	var _fetchedResultsController:
		NSFetchedResultsController<Base3DFormat>? = nil
	
	deinit {
		NotificationCenter
			.default
			.removeObserver(self,
							name: .NSManagedObjectContextObjectsDidChange,
							object: managedObjectContext)
	}
	
	init(managedObjectContext: NSManagedObjectContext) {
		self.managedObjectContext = managedObjectContext
		super.init()
		
		// this listens for changes to the moc and triggers an event.
		NotificationCenter.default
			.addObserver(self,
						 selector: #selector(managedObjectsDidChangeHandler(notification:)),
						 name: .NSManagedObjectContextObjectsDidChange,
						 object: managedObjectContext)
	}
	
	@objc fileprivate func managedObjectsDidChangeHandler(notification: NSNotification) {
		if let _ = notification.userInfo?["deleted"] {
			delegate?.shouldRemove()
			return
		}
		delegate?.shouldRefresh()
	}
	
	func getFileForID(baseFileId id: UUID) -> Base3DFormat? {
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Base3DFormat")
		fetch.predicate = NSPredicate(format: "id == %@", id.uuidString)
		do {
			if let results = try managedObjectContext.fetch(fetch) as? [Base3DFormat] {
				return results.first
			}
		} catch {
			fatalError("unable to find object with id \(id.uuidString)")
		}
		return nil
	}
	
	func importFile(filename: String,
					data: Data,
					imageData: Data?,
					thumbnailData: Data?) {
		
		let new3D = Base3DFormat(context: managedObjectContext)
		new3D.id = UUID()
		
		new3D.filename = filename
		new3D.imageFull = imageData
		new3D.imageThumbnail = thumbnailData
		new3D.size = Int32(data.count)
		new3D.created = Date()
		new3D.derivedFormats = nil
		new3D.data = imageData
		
		do {
			try managedObjectContext.save()
			print("import file \(filename) done.")
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
	
	func updateConvertProgress(file: Base3DFormat,
							   targetFormat format: ShaprOutputFormat,
							   progress: Float,
							   created: Date?,
							   data: Data?) {
		
		// get the object, update it.
		// if not yet found, create it, and then update it.
		
		var derivedFormat: Derived3DFormat?
		
		// look for the object now, if you can find it.
		if let derivedFormats = file.derivedFormats?.allObjects as? [Derived3DFormat],
			let foundFormat = derivedFormats.filter({ $0.fileExtension == format.rawValue })
				.first {
			// set exists, locate the matching object
			derivedFormat = foundFormat
		}
		
		if file.derivedFormats == nil {
			file.derivedFormats = NSSet()
		}
		
		// set is there, you can just add the object.
		
		if derivedFormat == nil {
			derivedFormat = Derived3DFormat(context: managedObjectContext)
			derivedFormat?.id = UUID()
			derivedFormat?.fileExtension = format.rawValue
		}
		
		file.derivedFormats = NSSet(set: file.derivedFormats!.adding(derivedFormat!))
		
		derivedFormat?.convertProgress = progress
		derivedFormat?.created = created
		derivedFormat?.data = data
		derivedFormat?.size = Int32(data?.count ?? 0)
		
		do {
			try managedObjectContext.save()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
		
	}
	
	func objectAtIndex(_ index: Int) -> Base3DFormat {
		return fetchedResultsController
			.object(at: IndexPath(row: index, section: 0))
	}
	
	func count() -> Int {
		let sectionInfo = fetchedResultsController.sections![0]
		return sectionInfo.numberOfObjects
	}
	
	func deleteAtIndex(_ index: Int) {
		let context = fetchedResultsController.managedObjectContext
		context.delete(fetchedResultsController
			.object(at: IndexPath(row: index, section: 0)))
		
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
}
