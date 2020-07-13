//
//  AppDelegate+Appearance.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

extension AppDelegate {
		
	/// Configures the standard navbar appearance
	static func setUpNavigationBarGeneralAppearance() {
		let setAppearance = { (bar: UINavigationBar) in
			bar.barStyle = .default
			bar.titleTextAttributes = [
				.font: FontUtilities.roundedFont(ofSize: 18, weight: .semibold)
			]
			bar.tintColor = .darkGray
		}
		setAppearance(UINavigationBar.appearance())
	}
}
