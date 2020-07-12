//
//  MasterViewController.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter

class MasterViewController: UITableViewController, ShaprDocumentPickerDelegate {

	var detailViewController: DetailViewController? = nil

	var documentPicker: ShaprDocumentPicker!
	
	lazy var dataManager: DataManager = {
		let manager = ACDataManager()
		manager.delegate = self
		return manager
	}()
	
	lazy var convertQueue: ConvertQueue = {
		let queue = ConversionQueue(converter: Converter())
		return queue
	}()
		
	override func viewDidLoad() {
		super.viewDidLoad()
		configureView()
		
		if dataManager.numberOfRows() == 0 {
			dataManager.createSampleFiles(5)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	func configureView() {
		
		let editButton = UIBarButtonItem(barButtonSystemItem: .edit,
										target: self,
										action: #selector(editPressed(_:)))
		
		navigationItem.leftBarButtonItem = editButton
		
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
	
	@objc func editPressed(_ sender: Any) {
		isEditing = !isEditing
	}
	
	@objc func pickPressed(_ sender: Any) {
		if let bbItem = sender as? UIBarButtonItem {
			documentPicker.present(from: bbItem)
		}
	}
	
	func didPickDocument(document: ShaprDocument?) {
		guard let doc = document else { return }
		doc.open { [weak self] success in
			if success, let data = doc.data {
				let filename = doc.fileURL.lastPathComponent
				self?.dataManager
					.importFile(filename: filename, data: data)
			}
		}
	}
		
	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier == "showDetail",
			let indexPath = tableView.indexPathForSelectedRow else { return }
		
		let object = dataManager.objectAtIndex(indexPath.row)
		let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
		controller.item = object
		controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		controller.navigationItem.leftItemsSupplementBackButton = true
		
		detailViewController = controller
		detailViewController?.delegate = self
	}
}

extension MasterViewController: DetailViewControllerDelegate {
	
	func requestedConversion(baseFileId id: UUID, to format: ShaprOutputFormat) {
		
		guard let file = dataManager.getFileForID(baseFileId: id),
			let fileData = file.data else {
			print("no data found.")
			return
		}
		
		convertQueue.add(id: id, data: fileData, format: format) { [weak self] info  in
			self?.dataManager.setConvertProgress(file: file,
												 targetFormat: format,
												 progress: info.progress,
												 created: info.created,
												 data: info.data)
		}
	}
}

extension MasterViewController: FetchedResultsManagerDelegate {
	
	func willChange() {
		tableView.beginUpdates()
	}
	
	func didChange() {
		tableView.endUpdates()
	}
	
	func shouldRefresh() {
		tableView.reloadData()
		detailViewController?.itemUpdated()
	}
	
	func insertAt(_ indexPaths: [IndexPath]) {
		tableView.insertRows(at: indexPaths, with: .fade)
	}
	
	func deleteAt(_ indexPaths: [IndexPath]) {
		tableView.deleteRows(at: indexPaths, with: .fade)
	}
}
