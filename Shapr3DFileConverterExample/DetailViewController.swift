//
//  DetailViewController.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter

class DetailViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var detailLabel: UILabel!
	
	@IBOutlet weak var headerLabel: UILabel!
	
	func configureView() {
		if let item = item {
			showElements(true)
			
			headerLabel?.text = item.filename
			detailLabel?.text = "\(item.size) bytes"
			imageView?.image = item.image
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
	}

	var item: ShaprFile? {
		didSet {
		    // Update the view.
		    configureView()
		}
	}
}

