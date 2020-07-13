//
//  TagsLayout.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

public enum ContentAlign {
	case left
	case right
}

public class ContentAlignableLayout: BaseLayout {
	public var contentAlign: ContentAlign = .left
}

public class TagsLayout: ContentAlignableLayout {
		
	override public func calculateCollectionViewFrames() {
		calculateHorizontalScrollDirection()
	}
		
	func calculateHorizontalScrollDirection() {
		guard let collectionView = collectionView, let delegate = delegate else {
			return
		}
		
		contentSize.height = collectionView.frame.size.height
		
		var xOffset = contentPadding.horizontal
		var yOffset = contentPadding.vertical
		
		for section in 0..<collectionView.numberOfSections {
			let itemsCount = collectionView.numberOfItems(inSection: section)
			
			var rowsCount = 0
			var xOffsets = [CGFloat]()
			
			for item in 0 ..< itemsCount {
				let isLastItem = item == itemsCount - 1
				let indexPath = IndexPath(item: item, section: section)
				let cellSize = delegate.cellSize(indexPath: indexPath)
				
				if yOffset + cellSize.height + cellsPadding.vertical > contentSize.height {
					yOffset = contentPadding.vertical
					rowsCount = item
				}
				
				let isFirstColumn = rowsCount == 0
				let row = isFirstColumn ? 0 : item % rowsCount
				let isValidRow = row < xOffsets.count
				
				let x = isFirstColumn || !isValidRow ? xOffset : xOffsets[row]
				let origin = CGPoint(x: x, y: yOffset)
				
				let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
				attributes.frame = CGRect(origin: origin, size: cellSize)
				cachedAttributes.append(attributes)
				
				if isFirstColumn {
					xOffsets.append(xOffset + cellSize.width + cellsPadding.horizontal)
				} else if isValidRow {
					let x = xOffsets[row]
					xOffsets[row] = x + cellSize.width + cellsPadding.horizontal
				}
				
				yOffset += cellSize.height + cellsPadding.vertical
				
				if isLastItem {
					xOffset = xOffsets.max()!
					yOffset = contentPadding.vertical
					
					xOffsets.removeAll()
					rowsCount = 0
				}
			}
		}
		
		contentSize.width = xOffset - cellsPadding.horizontal + contentPadding.horizontal
	}
}
