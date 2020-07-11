//
//  ShaprDocumentPicker.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

protocol ShaprDocumentPickerDelegate: class {
	func didPickDocument(document: ShaprDocument?)
}

open class ShaprDocumentPicker: NSObject {
	
	private var pickerController: UIDocumentPickerViewController?
	private weak var presentationController: UIViewController?
	private weak var delegate: ShaprDocumentPickerDelegate?

	private var document: ShaprDocument?
	
	init(presentationController: UIViewController,
		 delegate: ShaprDocumentPickerDelegate) {
		super.init()
		self.presentationController = presentationController
		self.delegate = delegate
	}
	
	public func present(from barButtonItem: UIBarButtonItem) {
		
		self.pickerController = UIDocumentPickerViewController(
			documentTypes: ["public.data"], in: .open)
		self.pickerController!.delegate = self
		self.pickerController!.allowsMultipleSelection = true
		self.presentationController?.present(self.pickerController!,
											 animated: true)
	}
	
}

extension ShaprDocumentPicker: UIDocumentPickerDelegate {
	
	public func documentPicker(_ controller: UIDocumentPickerViewController,
							   didPickDocumentsAt urls: [URL]) {
		
		guard let url = urls.first else { return }
		documentFromURL(pickedURL: url)
		delegate?.didPickDocument(document: document)
	}
	
	public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		delegate?.didPickDocument(document: nil)
	}
	
	private func documentFromURL(pickedURL: URL) {
		document = ShaprDocument(fileURL: pickedURL)
	}
}
