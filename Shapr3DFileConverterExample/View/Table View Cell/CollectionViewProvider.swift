//
//  CollectionViewProvider.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter

class CollectionViewProvider: NSObject, UICollectionViewDataSource {
	
	var items = [[ShaprOutputFormat]]()
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return items[section].count
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell",
													  for: indexPath)
		
		if let cell = cell as? ContentCell {
			let item = items[indexPath.section][indexPath.row]
			cell.populate(with: item)
		}
		
		return cell
	}
}
