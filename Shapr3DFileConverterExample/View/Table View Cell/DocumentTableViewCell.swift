//
//  DocumentTableViewCell.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter

class DocumentTableViewCell: UITableViewCell, LayoutDelegate {
	
	@IBOutlet weak var tagsCollectionView: UICollectionView! {
		didSet {
			tagsCollectionView.backgroundColor = .clear
			tagsCollectionView.isScrollEnabled = false
			tagsCollectionView.isUserInteractionEnabled = false
		}
	}

	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var headerLabel: UILabel! {
		didSet {
			headerLabel.font = FontUtilities.roundedFont(ofSize: 16, weight: .bold)
		}
	}
	
	@IBOutlet weak var detailLabel: UILabel! {
		didSet {
			detailLabel.font = FontUtilities.roundedFont(ofSize: 12, weight: .regular)
		}
	}
	
	private let collectionViewProvider = CollectionViewProvider()
	
	private var cellSizes = [[CGSize]]()
	
	private let layout: TagsLayout = {
		let ret = TagsLayout()
		ret.contentPadding = ItemsPadding(horizontal: 0, vertical: 0)
		ret.cellsPadding = ItemsPadding(horizontal: 4, vertical: 0)
		return ret
	}()
	
	static var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return df
	}()
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		tagsCollectionView.dataSource = collectionViewProvider
		tagsCollectionView.collectionViewLayout = layout
		
		layout.delegate = self
    }
	
	func setTags(_ tags: [ShaprOutputFormat]) {
		collectionViewProvider.items = [tags]
		prepareCellSizes()
		
		tagsCollectionView.setContentOffset(.zero, animated: false)
		tagsCollectionView.reloadData()
	}
	
	private func prepareCellSizes() {
		cellSizes.removeAll()
		
		collectionViewProvider.items.forEach { items in
			let sizes = items.map { item -> CGSize in
				let width = Double(self.tagsCollectionView.bounds.width)
				var size = UIFont.boldSystemFont(ofSize: 10)
					.sizeOfString(string: item.rawValue,
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
		
		let date = DocumentTableViewCell.dateFormatter.string(from: created)
		
		var formatProgress = [String: Float]()
		// get all the formats stored, and their progress
		file.derivedFormats?.forEach({ (df) in
			if let df = df as? Derived3DFormat  {
				formatProgress[df.fileExtension!] = df.convertProgress
			}
		})
		
		let firstKV = formatProgress.filter { $0.value < 1 }.first
		
		var progressStr: String = ""
		
		if let firstKV = firstKV {
			progressStr = String(format: "Exporting %@... %0.1f%%",
								 firstKV.key,
								 firstKV.value * 100.0)
		} else {
			progressStr = String(format: "%@", date)
		}
		
		detailLabel?.text = progressStr
		imageView?.image = thumbnail.scaledImage
		
		setTags(file.availableFormats(includeShapr: false))
	}
	
	// MARK: - LayoutDelegate
	
	func cellSize(indexPath: IndexPath) -> CGSize {
		return cellSizes[indexPath.section][indexPath.row]
	}
	
	func headerHeight(indexPath: IndexPath) -> CGFloat {
		return 0
	}
	
	func footerHeight(indexPath: IndexPath) -> CGFloat {
		return 0
	}
}

extension UIFont {
	func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
		return NSString(string: string)
			.boundingRect(with:
				CGSize(width: width, height: Double.greatestFiniteMagnitude),
						  options: NSStringDrawingOptions.usesLineFragmentOrigin,
						  attributes: [NSAttributedString.Key.font: self],
						  context: nil).size
	}
}
