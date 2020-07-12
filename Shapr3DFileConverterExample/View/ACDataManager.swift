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

protocol FetchedResultsManagerDelegate: class {
	func willChange()
	func didChange()
	func shouldRefresh()
	func insertAt(_ indexPaths: [IndexPath])
	func deleteAt(_ indexPaths: [IndexPath])
}

protocol DataManager {
	func importFile(filename: String, data: Data)
	func getFileForID(baseFileId id: UUID) -> Base3DFormat?
	func setConvertProgress(file: Base3DFormat,
							targetFormat format: ShaprOutputFormat,
							progress: Float,
							created: Date?,
							data: Data?)
	func objectAtIndex(_ index: Int) -> Base3DFormat
	func numberOfRows() -> Int
	func deleteAtIndex(_ index: Int)
}

class ACDataManager: NSObject, DataManager, NSFetchedResultsControllerDelegate {
	
	weak var delegate: FetchedResultsManagerDelegate?
	
	var managedObjectContext: NSManagedObjectContext? = nil
	
	deinit {
		NotificationCenter
			.default
			.removeObserver(self,
							name: .NSManagedObjectContextObjectsDidChange,
							object: managedObjectContext)
	}
	
	override init() {
		super.init()
		
		self.managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
		
		NotificationCenter
			.default
			.addObserver(self,
						 selector: #selector(managedObjectsDidChangeHandler(notification:)),
						 name: .NSManagedObjectContextObjectsDidChange,
						 object: managedObjectContext)
	}
	
	@objc fileprivate func managedObjectsDidChangeHandler(notification: NSNotification) {
		delegate?.shouldRefresh()
	}
	
	func getFileForID(baseFileId id: UUID) -> Base3DFormat? {
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Base3DFormat")
		fetch.predicate = NSPredicate(format: "id == %@", id.uuidString)
		do {
			if let results = try managedObjectContext!.fetch(fetch) as? [Base3DFormat] {
				return results.first
			}
		} catch {
			fatalError("unable to find object with id \(id.uuidString)")
		}
		return nil
	}
	
	func importFile(filename: String, data: Data) {
		guard let context = self.managedObjectContext else {
			fatalError("unable to get managed object context from FRC")
		}
		
		let new3D = Base3DFormat(context: context)
		new3D.id = UUID()
		
		let imgData = imageData(filename: filename, id: new3D.id!)
		new3D.filename = filename
		new3D.imageFull = imgData
		new3D.imageThumbnail = imageData(filename: filename, id: new3D.id!, thumb: true)
		new3D.size = Int32(data.count)
		new3D.created = Date()
		new3D.derivedFormats = nil
		new3D.data = imgData
		
		do {
			try managedObjectContext?.save()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
	
	func setConvertProgress(file: Base3DFormat,
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
			derivedFormat = Derived3DFormat(context: managedObjectContext!)
			derivedFormat?.id = UUID()
			derivedFormat?.base = file
			derivedFormat?.fileExtension = format.rawValue
		}
		
		file.derivedFormats = NSSet(set: file.derivedFormats!.adding(derivedFormat!))
		
		derivedFormat?.convertProgress = progress
		derivedFormat?.created = created
		derivedFormat?.data = data
		derivedFormat?.size = Int32(data?.count ?? 0)
		
		if let context = file.managedObjectContext {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	func objectAtIndex(_ index: Int) -> Base3DFormat {
		return fetchedResultsController
			.object(at: IndexPath(row: index, section: 0))
	}
	
	func numberOfRows() -> Int {
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
	
	// MARK: - FetchedResultsController
	
	private var _fetchedResultsController:
		NSFetchedResultsController<Base3DFormat>? = nil
	
	private var fetchedResultsController: NSFetchedResultsController<Base3DFormat> {
		
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
		case .insert: delegate?.insertAt([newIndexPath!])
		case .delete: delegate?.deleteAt([indexPath!])
		default: return
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.didChange()
	}
}

extension ACDataManager {
	
	func imageData(filename: String, id: UUID, thumb: Bool = false) -> Data? {
		
		let possibleImages = [
			"burden",
			"khaprenko",
			"meiying",
			"pat-kay",
			"patrick-ryan",
			"pawel-czerwinski",
			"pawel-czerwinski-2",
			"peter-nguyen",
			"ren-ran",
			"s-s",
			"samsomfotos",
			"samuel-zeller",
			"spencer-davis",
			"spratt",
			"swan-leroi",
			"t-h-chia",
			"tyler-casey",
			"vince-russell",
			"william-warby",
			"willian-justen-de-vasconcellos",
			"yuiizaa-september",
			"yuriy-garnaev",
		]
		
		// arbitrary based on filename
		let index = abs(id.uuidString.hashValue) % possibleImages.count
		let imageName = possibleImages[index]
		
		let fullName = "\(imageName)-full"
		let thumbName = "\(imageName)-thumb"
		
		let name = thumb ? thumbName : fullName
		var image = UIImage(named: name)
		
		if thumb {
			image = image?.makeRounded(radius: 4)
		}
		
		return image?.pngData()
	}
}
