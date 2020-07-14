//
//  SceneDelegate.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let window = window else { return }
		guard let splitViewController = window.rootViewController as? UISplitViewController else { return }
		guard let navigationController = splitViewController.viewControllers.last as? UINavigationController else { return }
		navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
		navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true
		splitViewController.delegate = self
		splitViewController.preferredDisplayMode = .allVisible
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
	}

	// MARK: - Split view

	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
	    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
	    guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
	    if topAsDetailController.item == nil {
	        return true
	    }
	    return false
	}
}
