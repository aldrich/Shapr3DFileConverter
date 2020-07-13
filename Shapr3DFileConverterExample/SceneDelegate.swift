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
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let window = window else { return }
		guard let splitViewController = window.rootViewController as? UISplitViewController else { return }
		guard let navigationController = splitViewController.viewControllers.last as? UINavigationController else { return }
		navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
		navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true
		splitViewController.delegate = self
		splitViewController.preferredDisplayMode = .allVisible

	}

	func sceneDidDisconnect(_ scene: UIScene) {
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
	}

	func sceneWillResignActive(_ scene: UIScene) {
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
	}

	// MARK: - Split view

	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
	    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
	    guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
	    if topAsDetailController.item == nil {
	        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
	        return true
	    }
	    return false
	}
}
