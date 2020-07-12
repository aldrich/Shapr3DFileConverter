//
//  FileInfoTableViewController.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter

class FileInfoTableViewController: UITableViewController {
	
	var item: Base3DFormat? {
		didSet {
			if let item = item {
				generateSectionSource(with: item)
			}
		}
	}
	
	var sectionTitles = [String]()
	var sections = [[String]]()
	
	func generateSectionSource(with item: Base3DFormat) {
	
		let formatDate = { (date: Date, prefix: String) -> String in
			let dateStr = DateUtilities.dateFormatter.string(from: date)
			return String(format: "%@%@", prefix, dateStr)
		}
		
		let formatSize = { (size: Int32) -> String in
			UnitUtilities.byteCountFormatter.string(fromByteCount: Int64(size))
		}
		
		sectionTitles = ["Information"]
				
		let topSection = [
			item.filename!,
			formatDate(item.created!, "Created: "),
			formatSize(item.size),
			item.id!.uuidString
		]
		
		sections = [topSection]
		
		let additionalSections: [[String]] = item.convertedFormats.map { converted in
			[
				formatDate(converted.created!, "Exported: "),
				formatSize(converted.size),
				converted.id!.uuidString
			]
		}
		
		sectionTitles.append(contentsOf: item.convertedFormats.map { $0.fileExtension! })
		sections.append(contentsOf: additionalSections)
		
		// be careful, no checking here yet!
		tableView.reloadData()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		preferredContentSize = CGSize(width: 320, height: 400)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		tableView.allowsSelection = false
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionTitles[section]
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		cell.textLabel?.font = FontUtilities.roundedFont(ofSize: 15, weight: .regular)
		cell.textLabel?.text = sections[indexPath.section][indexPath.row]
		return cell
	}
}
