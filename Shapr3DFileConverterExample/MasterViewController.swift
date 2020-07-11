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
		
	}
	
	lazy var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return df
	}()
	
	@objc
	func pickPressed(_ sender: Any) {
		if let bbItem = sender as? UIBarButtonItem {
			documentPicker.present(from: bbItem)
		}
		
		Converter().foo()
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

	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	private func insert3DFile(filename: String, data: Data) {
		let context = self.fetchedResultsController.managedObjectContext
		let new3D = Base3DFormat(context: context)
		
		new3D.filename = filename
		new3D.derivedFormats = nil
		new3D.imageFull = imageData(filename: filename)
		new3D.imageThumbnail = imageData(filename: filename, thumb: true)
		new3D.size = Int32(data.count)
		new3D.created = Date()
		
		//!
		// let's fake it for now
		let derived = Derived3DFormat(context: context)
		derived.convertProgress = 0.18
		derived.base = new3D
		derived.created = Date()
		derived.size = 92838
		derived.fileExtension = "obj"
		
		new3D.derivedFormats = NSSet(array: [derived])

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
				controller.item = ShaprFile(fileEntity: object)
		        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		        detailViewController = controller
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
			let shaprFile = ShaprFile(fileEntity: file)
			configureCell(cell, shaprFile: shaprFile)
			return cell
		}
		
		return UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

	func configureCell(_ cell: DocumentTableViewCell, shaprFile file: ShaprFile) {
		cell.headerLabel?.text = file.filename
		
		let date = self.dateFormatter.string(from: file.created)
		
		// get any derivedFormat whose convertProgress is not yet 1
		let progress = file.derivedFormats.filter { $0.convertProgress < 1.0 }
			.map { $0.convertProgress }
			.first
		
		var progressStr: String = ""
		if let progress = progress {
			progressStr = String(format: "%0.1f%%", progress * 100.0)
		}
		
		
		cell.detailLabel?.text = "\(date) - \(progressStr)"
		cell.imageView?.image = file.thumbnail
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

