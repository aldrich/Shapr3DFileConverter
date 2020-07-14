//
//  DocumentTableViewCell.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter
import CoreGraphics

class DocumentTableViewCell: UITableViewCell, LayoutDelegate {
	
	@IBOutlet weak var tagsCollectionView: UICollectionView! {
		didSet {
			tagsCollectionView.backgroundColor = .clear
			tagsCollectionView.isScrollEnabled = false
			tagsCollectionView.isUserInteractionEnabled = false
			tagsCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1);
		}
	}

	@IBOutlet weak var iconImageView: UIImageView!
	
	@IBOutlet weak var headerLabel: UILabel! {
		didSet {
			headerLabel.font = TextUtilities.roundedFont(ofSize: 16, weight: .semibold)
		}
	}
	
	@IBOutlet weak var detailLabel: UILabel! {
		didSet {
			detailLabel.font = TextUtilities.roundedFont(ofSize: 12, weight: .regular)
		}
	}
	
	private let collectionViewProvider = CollectionViewProvider()
	
	private var cellSizes = [[CGSize]]()
	
	private let layout: TagsLayout = {
		let ret = TagsLayout()
		
		ret.contentPadding = ItemsPadding(horizontal: 0, vertical: 2)
		
		ret.cellsPadding = ItemsPadding(horizontal: 4, vertical: 0)
		return ret
	}()
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		tagsCollectionView.dataSource = collectionViewProvider
		tagsCollectionView.collectionViewLayout = layout
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
		selectedBackgroundView = backgroundView
		
		layout.delegate = self
    }
	
	private func prepareCellSizes() {
		cellSizes.removeAll()
		
		collectionViewProvider.items.forEach { items in
			let sizes = items.map { item -> CGSize in
				let width = Double(self.tagsCollectionView.bounds.width)
				var size = TextUtilities.sizeOfString(string: item.rawValue,
													  font: .boldSystemFont(ofSize: 10),
													  constrainedToWidth: width)
				size.width += 10
				size.height += 0
				return size
			}
			cellSizes.append(sizes)
		}
	}
	
	func configureWith(_ file: Base3DFormat) {
		
		guard let created = file.created,
			let _ = file.derivedFormats,
			let thumbnail = file.imageThumbnail else {
				fatalError("missing values for required properties")
		}
		
		headerLabel?.text = file.filename
		
		let date = DateUtilities.dateFormatter.string(from: created)
		
		detailLabel?.text = file.getProgressString() ?? date
		
		imageView?.image = thumbnail.scaledImage
		
		setTags(file.availableFormats(includeShapr: false))
	}
	
	private func setTags(_ tags: [ShaprOutputFormat]) {
		collectionViewProvider.items = [tags]
		prepareCellSizes()
		
		tagsCollectionView.setContentOffset(.zero, animated: false)
		tagsCollectionView.reloadData()
	}
	
	// MARK: - LayoutDelegate
	
	func cellSize(indexPath: IndexPath) -> CGSize {
		return cellSizes[indexPath.section][indexPath.row]
	}
}

extension Base3DFormat {
	
	func getProgressString() -> String? {
		
		// collect all the formats stored, and their progress
		var formatProgress = [String: Float]()
		
		derivedFormats?.forEach { df in
			if let df = df as? Derived3DFormat  {
				formatProgress[df.fileExtension!] = df.convertProgress
			}
		}
		
		let firstKV = formatProgress.filter { $0.value < 1 }.first
		
		var progressStr: String?
		
		if let firstKV = firstKV {
			progressStr = String(format: "Exporting %@... %0.1f%%",
								 firstKV.key,
								 firstKV.value * 100.0)
		}
		return progressStr
	}
}
