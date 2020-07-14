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
	
	func detailViewRequestedConversion(baseFileId id: UUID, to format: ShaprOutputFormat)
	
}

class DetailViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView! {
		didSet {
			imageView.layer.cornerRadius = 10
		}
	}
	
	@IBOutlet weak var headerLabel: UILabel! {
		didSet {
			headerLabel.font = TextUtilities.roundedFont(ofSize: 14,
														 weight: .bold)
		}
	}
	
	@IBOutlet weak var detailLabel: UILabel! {
		didSet {
			detailLabel.font = TextUtilities.roundedFont(ofSize: 12,
														 weight: .regular)
		}
	}
	
	@IBOutlet weak var creditsLabel: UILabel! {
		didSet {
			creditsLabel.font = TextUtilities.roundedFont(ofSize: 10,
														  weight: .regular)
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
		configureView(onLoad: true)
		configureNavBar()
	}
	
	func configureNavBar() {
		guard let item = item else {
			navigationItem.rightBarButtonItem = nil
			navigationItem.title = nil
			return
		}
		
		let editButton = UIBarButtonItem(barButtonSystemItem: .bookmarks,
										 target: self,
										 action: #selector(showInfoPopup))

		let actionButton = UIBarButtonItem(barButtonSystemItem: .action,
										   target: self,
										   action: #selector(showExportsOptionsPopup))
		
		navigationItem.rightBarButtonItems = [actionButton, editButton]
		navigationItem.title = item.filename
	}
	
	// call this when derivedObjects is updated.
	func itemUpdated(isRemoved: Bool = false) {
		if isRemoved {
			self.item = nil
		}
		configureView()
	}
	
	func configureView(onLoad: Bool = false) {
		
		guard let item = item else {
			showElements(false)
			return
		}
		
		showElements(true, animate: onLoad)
		
		headerLabel?.text = item.filename
		
		detailLabel?.text = item.detailString
		
		imageView?.image = item.imageFull?.scaledImage
		
		configureProgressHud(item: item)
	}
	
	// show or hide the progress hud depending on details found in item (note
	// that conversion progress can be gathered from Derived3DFormat)
	private func configureProgressHud(item: Base3DFormat) {
		
		guard let formatUndergoingConversion = item.formatsUndergoingExport.first else {
			hud?.hide(animated: false)
			hud = nil
			return
		}
		
		// there's an ongoing conversion
		let outputFormatStr = formatUndergoingConversion.fileExtension ?? "unknown"
		if hud == nil {
			hud = MBProgressHUD.showAdded(to: view, animated: true)
			hud?.removeFromSuperViewOnHide = true
			hud?.mode = .determinate
			hud?.label.text = "Exporting to \(outputFormatStr) ..."
		} else {
			hud?.show(animated: true)
		}
		hud?.progress = formatUndergoingConversion.convertProgress
	}
	
	private func showElements(_ show: Bool, animate: Bool = false) {
		headerLabel?.isHidden = !show
		detailLabel?.isHidden = !show
		creditsLabel?.isHidden = !show
		
		if show {
			imageView?.alpha = 0
			if animate {
				UIView.animate(withDuration: 0.25) {
					self.imageView?.alpha = 1
				}
			} else {
				imageView?.alpha = 1
			}
			imageView.contentMode = .scaleAspectFill
			
		} else {
			imageView.alpha = 1
			imageView.image = UIImage(named: "detail-view-empty")
			imageView.contentMode = .scaleAspectFit
		}
	}
	
	@objc func showInfoPopup(sender: UIBarButtonItem) {
		guard let item = item else {
			fatalError("file has no id")
		}
		let vc = FileInfoTableViewController(style: .insetGrouped)
		vc.modalPresentationStyle = .popover
		vc.popoverPresentationController?.barButtonItem = sender
		vc.item = item
		present(vc, animated: true)
	}
	
	@objc func showExportsOptionsPopup(sender: UIBarButtonItem) {
		
		guard let item = item, let fileBaseId = item.id else {
			fatalError("file has no id")
		}
		
		guard item.formatsUndergoingExport.count < 1 else {
			return
		}
		
		let requestConvert = { [weak self] (format: ShaprOutputFormat) -> Void in
			self?.delegate?.detailViewRequestedConversion(baseFileId: fileBaseId, to: format)
		}
		
		let actionSheet = UIAlertController(title: nil,
											message: "Select a format to export to",
											preferredStyle: .actionSheet)
		
		actionSheet.modalPresentationStyle = .popover
		actionSheet.popoverPresentationController?.barButtonItem = sender

		let availableFormats = item.formatsAvailableForExport
		// get each format still not found, and then add them as options.
		if availableFormats.count > 0 {
			availableFormats.forEach { format in
				let formatStr = format.rawValue
				let title = "Export to \(formatStr)"
				let action = UIAlertAction(title: title, style: .default) { _ in
					requestConvert(format)
				}
				actionSheet.addAction(action)
			}
		} else {
			let message = "All available formats exported"
			actionSheet.addAction(UIAlertAction(title: message,
												style: .default,
												handler: nil))
		}
		
		actionSheet.addAction(UIAlertAction(title: "Cancel",
											style: .cancel) { _ in })
		
		present(actionSheet, animated: true)
	}
}

extension Base3DFormat {
	
	// use format details to determine view-specific value for detailLabel
	var detailString: String {
		let formats = availableFormats(includeShapr: false)
			.map { $0.rawValue }
			.sorted()
			.joined(separator: ", ")
		
		if formats.count > 0 {
			return "Exported formats: \(formats)"
		} else {
			return String(format: "Created: %@",
						  DateUtilities.dateFormatter
							.string(from: created ?? Date()))
		}
	}
}
