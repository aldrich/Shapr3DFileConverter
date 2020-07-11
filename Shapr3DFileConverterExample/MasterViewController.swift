//
//  MasterViewController.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import CoreData
import Shapr3DFileConverter

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, ShaprDocumentPickerDelegate {

	var detailViewController: DetailViewController? = nil
	var managedObjectContext: NSManagedObjectContext? = nil

	var documentPicker: ShaprDocumentPicker!
	
	let convertQueue: ConvertQueue = ConversionQueue(converter: Converter())

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = editButtonItem

		let addButton = UIBarButtonItem(barButtonSystemItem: .add,
										target: self,
										action: #selector(pickPressed(_:)))
		
		navigationItem.rightBarButtonItem = addButton
		if let split = splitViewController {
		    let controllers = split.viewControllers
		    detailViewController = (controllers[controllers.count-1] as! UINavigationController)
				.topViewController as? DetailViewController
		}
		
		documentPicker = ShaprDocumentPicker(presentationController: self,
											 delegate: self)
		
		NotificationCenter
			.default
			.addObserver(self,
						 selector: #selector(managedObjectsDidChangeHandler(notification:)),
						 name: .NSManagedObjectContextObjectsDidChange,
						 object: managedObjectContext)

		// willdisapppear
		// NotificationCenter.default
		// .removeObserver(self, name: .NSManagedObjectContextObjectsDidChange,
		// object: mainManagedContext)

	}
	
	@objc fileprivate func managedObjectsDidChangeHandler(notification: NSNotification) {
		tableView.reloadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	lazy var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return df
	}()
	
	@objc func pickPressed(_ sender: Any) {
		if let bbItem = sender as? UIBarButtonItem {
			documentPicker.present(from: bbItem)
		}
	}
	
	func didPickDocument(document: ShaprDocument?) {
		if let doc = document {
			doc.open { [weak self] success in
				if success, let data = doc.data {
					let filename = doc.fileURL.lastPathComponent
					self?.insert3DFile(filename: filename, data: data)
				}
			}
		}
	}
	
	private func insert3DFile(filename: String, data: Data) {
		let context = self.fetchedResultsController.managedObjectContext
		let new3D = Base3DFormat(context: context)
		
		let imgData = imageData(filename: filename)
		
		new3D.id = UUID()
		new3D.filename = filename
		new3D.imageFull = imgData
		new3D.imageThumbnail = imageData(filename: filename, thumb: true)
		new3D.size = Int32(data.count)
		new3D.created = Date()
		new3D.derivedFormats = nil
		new3D.data = imgData
		
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
	
	func imageData(filename: String, thumb: Bool = false) -> Data? {
		
		let possibleImages = [
			"burden",
			"khaprenko",
			"meiying",
			"spratt",
		]
		
		// arbitrary based on filename
		let index = abs(filename.hashValue) % possibleImages.count
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
	
	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = tableView.indexPathForSelectedRow {
				
		    let object = fetchedResultsController.object(at: indexPath)
		        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
				controller.item = object
		        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		        detailViewController = controller
				detailViewController?.delegate = self
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? DocumentTableViewCell {
			let file = fetchedResultsController.object(at: indexPath)
			configureCell(cell, base3dFile: file)
			return cell
		}
		
		return UITableViewCell()
	}

	override func tableView(_ tableView: UITableView,
							canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView,
							commit editingStyle: UITableViewCell.EditingStyle,
							forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
		    let context = fetchedResultsController.managedObjectContext
		    context.delete(fetchedResultsController.object(at: indexPath))
		        
		    do {
		        try context.save()
		    } catch {
		        let nserror = error as NSError
		        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		    }
		}
	}

	func configureCell(_ cell: DocumentTableViewCell, base3dFile file: Base3DFormat) {
		
		guard let created = file.created,
			let _ = file.derivedFormats,
			let thumbnail = file.imageThumbnail else {
				fatalError("missing values for required properties")
		}
		
		cell.headerLabel?.text = file.filename
		
		let date = self.dateFormatter.string(from: created)

		var formatProgress = [String: Float]()
		// get all the formats stored, and their progress
		file.derivedFormats?.forEach({ (df) in
			if let df = df as? Derived3DFormat  {
				formatProgress[df.fileExtension!] = df.convertProgress
			}
		})
		
		// get the first one not 1.
		let firstKV = formatProgress.filter { $0.value < 1 }.first
		
		var progressStr: String = ""
		
		if let firstKV = firstKV {
			progressStr = String(format: "converting %@ - %0.1f%%",
								 firstKV.key,
								 firstKV.value * 100.0)
		} else {
			progressStr = date
		}
		
		cell.detailLabel?.text = progressStr
		cell.imageView?.image = thumbnail.scaledImage
	}

	// MARK: - Fetched results controller

	var fetchedResultsController: NSFetchedResultsController<Base3DFormat> {
	    if _fetchedResultsController != nil {
	        return _fetchedResultsController!
	    }
	    
	    let fetchRequest: NSFetchRequest<Base3DFormat> = Base3DFormat.fetchRequest()
	    
	    // Set the batch size to a suitable number.
	    fetchRequest.fetchBatchSize = 20
	    
	    // Edit the sort key as appropriate.
	    let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
	    
	    fetchRequest.sortDescriptors = [sortDescriptor]
	    
	    // Edit the section name key path and cache name if appropriate.
	    // nil for section name key path means "no sections".
	    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
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

	var _fetchedResultsController: NSFetchedResultsController<Base3DFormat>? = nil

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	    tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange sectionInfo: NSFetchedResultsSectionInfo,
					atSectionIndex sectionIndex: Int,
					for type: NSFetchedResultsChangeType) {
	    switch type {
	        case .insert:
	            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
	        case .delete:
	            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
	        default:
	            return
	    }
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any, at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
	    switch type {
	        case .insert:
	            tableView.insertRows(at: [newIndexPath!], with: .fade)
	        case .delete:
	            tableView.deleteRows(at: [indexPath!], with: .fade)
	        default:
	            return
	    }
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	    tableView.endUpdates()
	}
}

extension MasterViewController: DetailViewControllerDelegate {
	
	func startConversion(baseFileId id: UUID, to format: FileExtension) {
		
		guard let file = getFileForID(baseFileId: id),
			let data = file.data else {
			print("no data found.")
			return
		}
		
		convertQueue.add(id: id, data: data, format: format) { [weak self] progress in
			guard let self = self else { return }
			var progressValue: Float = 0
			var finalData: Data?
			var created: Date?
			
			switch progress {
			case let .completed(data):
				progressValue = 1.0
				finalData = data
				created = Date()
				break
			case let .progress(progress):
				progressValue = progress
			case let .error(message):
				print(message)
			}
			
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
				derivedFormat = Derived3DFormat(context: self.moc)
				derivedFormat?.id = UUID()
				derivedFormat?.base = file
				derivedFormat?.fileExtension = format.rawValue
			}
			
			file.derivedFormats = NSSet(set: file.derivedFormats!.adding(derivedFormat!))
			
			derivedFormat?.convertProgress = progressValue
			derivedFormat?.created = created
			derivedFormat?.data = finalData
			derivedFormat?.size = Int32(finalData?.count ?? 0)
		
			if let context = file.managedObjectContext {
				do {
					try context.save()
				} catch {
					let nserror = error as NSError
					fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
				}
			}
		}
	}
	
	func getFileForID(baseFileId id: UUID) -> Base3DFormat? {
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Base3DFormat")
		fetch.predicate = NSPredicate(format: "id == %@", id.uuidString)
		do {
			if let results = try moc.fetch(fetch) as? [Base3DFormat] {
				return results.first
			}
		} catch {
			fatalError("unable to find object with id \(id.uuidString)")
		}
		return nil
	}
	
	var moc: NSManagedObjectContext {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		return appDelegate.persistentContainer.viewContext
	}
}
