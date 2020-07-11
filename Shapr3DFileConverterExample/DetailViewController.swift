//
//  DetailViewController.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter

protocol DetailViewControllerDelegate: class {
	func startConversion(baseFileId id: UUID, to format: FileExtension)
}

class DetailViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var detailLabel: UILabel!
	
	@IBOutlet weak var headerLabel: UILabel!
	
	weak var delegate: DetailViewControllerDelegate?
	
	func configureView() {
		if let item = item {
			showElements(true)
			
			headerLabel?.text = item.filename
			detailLabel?.text = "\(item.size) bytes"
			imageView?.image = item.imageFull?.scaledImage
			
			configureNavBar()
		}
	}
	
	func showElements(_ show: Bool) {
		headerLabel?.isHidden = !show
		detailLabel?.isHidden = !show
		imageView?.isHidden = !show
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		showElements(false)
		configureView()
		configureNavBar()
	}
	
	func configureNavBar() {
		guard let _ = item else {
			navigationItem.rightBarButtonItem = nil
			return
		}
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
															target: self,
															action: #selector(doConvert))
	}
	
	@objc
	func doConvert(sender: UIBarButtonItem) {
		
		guard let fileBaseId = item?.id else {
			fatalError("a file has no id")
		}
		
		let requestConvert = { [weak self] (format: FileExtension) -> Void in
			self?.delegate?.startConversion(baseFileId: fileBaseId, to: format)
		}
		
		let actionSheet = UIAlertController(title: nil,
											message: "Select a format to convert to",
											preferredStyle: .actionSheet)
		
		actionSheet.modalPresentationStyle = .popover
		actionSheet.popoverPresentationController?.barButtonItem = sender
		
		actionSheet.addAction(.init(title: "Convert to .obj", style: .default) { _ in
			requestConvert(.obj)
		})
		
		actionSheet.addAction(.init(title: "Convert to .step", style: .default) { _ in
			requestConvert(.step)
		})
		
		actionSheet.addAction(.init(title: "Convert to .stl", style: .default) { _ in
			requestConvert(.stl)
		})
		
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
		
		present(actionSheet, animated: true)
	}

	var item: Base3DFormat? {
		didSet {
		    // Update the view.
		    configureView()
		}
	}
}

