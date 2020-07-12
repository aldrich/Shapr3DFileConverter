//
//  DetailViewController.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter
import MBProgressHUD

protocol DetailViewControllerDelegate: class {
	func requestedConversion(baseFileId id: UUID, to format: ShaprOutputFormat)
}

class DetailViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var detailLabel: UILabel! {
		didSet {
			detailLabel.font = FontUtilities.roundedFont(ofSize: 12, weight: .regular)
		}
	}
	
	@IBOutlet weak var headerLabel: UILabel! {
		didSet {
			headerLabel.font = FontUtilities.roundedFont(ofSize: 14, weight: .bold)
		}
	}
	
	weak var delegate: DetailViewControllerDelegate?
	
	var hud: MBProgressHUD?
	
	var item: Base3DFormat? {
		didSet {
			configureNavBar()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		showElements(false)
		configureView()
		configureNavBar()
	}
	
	func configureNavBar() {
		guard let item = item else {
			navigationItem.rightBarButtonItem = nil
			navigationItem.title = nil
			return
		}
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
															target: self,
															action: #selector(showExportsOptionsPopup))
		navigationItem.title = item.filename
	}
	
	// call this when derivedObjects is updated.
	func itemUpdated() {
		configureView()
	}
	
	func configureView() {
		guard let item = item else { return }
		
		showElements(true)
		
		headerLabel?.text = item.filename
		
		let formats = item.availableFormats(includeShapr: false)
			.map { $0.rawValue }
			.sorted()
			.joined(separator: ", ")
		
		if formats.count > 0 {
			detailLabel?.text = "Exported formats: \(formats)"
		} else {
			detailLabel?.text = ""
		}
		
		imageView?.image = item.imageFull?.scaledImage
		
		if let ongoing = item.formatsUndergoingExport.first {
			// there's an ongoing conversion
			let outputFormatStr = ongoing.fileExtension ?? "unknown"
			if hud == nil {
				hud = MBProgressHUD.showAdded(to: view, animated: true)
				hud?.removeFromSuperViewOnHide = true
				hud?.mode = .determinate
				hud?.label.text = "Exporting to \(outputFormatStr) ..."
			} else {
				hud?.show(animated: true)
			}
			hud?.progress = ongoing.convertProgress
		} else {
			hud?.hide(animated: false)
			hud = nil
		}
	}
	
	var hasOngoingConversion: Bool {
		guard let item = item else {
			return false
		}
		return item.formatsUndergoingExport.count > 0
	}
	
	func showElements(_ show: Bool) {
		headerLabel?.isHidden = !show
		detailLabel?.isHidden = !show
		imageView?.isHidden = !show
	}
	
	@objc
	func showExportsOptionsPopup(sender: UIBarButtonItem) {
		
		guard let item = item, let fileBaseId = item.id else {
			fatalError("file has no id")
		}
		
		guard item.formatsUndergoingExport.count < 1 else {
			return
		}
		
		let requestConvert = { [weak self] (format: ShaprOutputFormat) -> Void in
			self?.delegate?.requestedConversion(baseFileId: fileBaseId, to: format)
		}
		
		let actionSheet = UIAlertController(title: nil,
											message: "Select a format to convert to",
											preferredStyle: .actionSheet)
		
		actionSheet.modalPresentationStyle = .popover
		actionSheet.popoverPresentationController?.barButtonItem = sender

		let availableFormats = item.formatsAvailableForExport
		// get each format still not found, and then add them as options.
		
		if availableFormats.count > 0 {
		
			availableFormats.forEach { format in
				let formatStr = format.rawValue
				let title = "Convert to \(formatStr)"
				let action = UIAlertAction(title: title, style: .default) { _ in
					requestConvert(format)
				}
				actionSheet.addAction(action)
			}
		} else {
			actionSheet.addAction(.init(title: "All available formats exported",
										style: .default,
										handler: nil))
		}
		
		actionSheet.addAction(UIAlertAction(title: "Cancel",
											style: .cancel) { _ in })
		
		present(actionSheet, animated: true)
	}
}


extension Base3DFormat {
	var formatsUndergoingExport: [Derived3DFormat] {
		derivedFormats?.allObjects
			.compactMap { $0 as? Derived3DFormat }
			.filter { $0.convertProgress < 1 }
			?? []
	}
	
	var formatsAvailableForExport: [ShaprOutputFormat] {
		
		let availableFormatsList: [ShaprOutputFormat] = [
			.obj, .step, .stl
		]
		
		// undergoing or completed (progress > 0)
		
		let unavailableOptions = derivedFormats?
			.allObjects
			.compactMap { $0 as? Derived3DFormat }
			.filter { $0.convertProgress > 0 }
			.compactMap { $0.fileExtension }
			.compactMap { ShaprOutputFormat(rawValue: $0) } ?? []
		
		return availableFormatsList.filter {
			!unavailableOptions.contains($0)
		}
	}
}
