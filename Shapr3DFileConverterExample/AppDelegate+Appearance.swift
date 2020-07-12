//
//  AppDelegate+Appearance.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

extension AppDelegate {
	
	/// Makes the navbar back button use the specified chevron image asset
	static func setNavigationBarButtonItemAppearance() {
		let backImage = UIImage(named: "back-button-item")?
			.withRenderingMode(.alwaysTemplate)
		UINavigationBar.appearance().backIndicatorImage = backImage
		UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
	}
	
	/// Configures the standard navbar appearance
	static func setUpNavigationBarGeneralAppearance() {
		let setAppearance = { (bar: UINavigationBar) in
			bar.barStyle = .default
			bar.titleTextAttributes = [
				.font: FontUtilities.roundedFont(ofSize: 18, weight: .bold)
			]
			bar.tintColor = .darkGray
		}
		setAppearance(UINavigationBar.appearance())
	}
}

extension UIBarButtonItem {
	static func backButtonItem(tintColor: UIColor = .black) -> UIBarButtonItem {
		let backButtonItem = UIBarButtonItem(title: "", style: .plain,
											 target: nil, action: nil)
		backButtonItem.tintColor = tintColor
		return backButtonItem
	}
}
