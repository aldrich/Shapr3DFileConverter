//
//  MasterViewController+UITableView.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//
import UIKit

extension MasterViewController {

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView,
							numberOfRowsInSection section: Int) -> Int {
		return dataManager.numberOfRows()
	}
	
	override func tableView(_ tableView: UITableView,
							cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? DocumentTableViewCell {
			let file = dataManager.objectAtIndex(indexPath.row)
			cell.configureWith(file)
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
			dataManager.deleteAtIndex(indexPath.row)
		}
	}
}
