//
//  AppDelegate.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Cocoa
import ServiceManagement

private func activateLoginItems(from bundle: Bundle, using fileManager: FileManager) {
	let loginItemsFolder = bundle.bundleURL.appendingPathComponent("Contents").appendingPathComponent("Library").appendingPathComponent("LoginItems")
	let items = try! fileManager.contentsOfDirectory(atPath: loginItemsFolder.path)

	for item in items {
		guard
			let bundle = Bundle(path: item),
			let bundleIdentifier = bundle.bundleIdentifier
		else { continue }
		if !SMLoginItemSetEnabled(bundleIdentifier as CFString, true) {
			print("Unable to enable \(bundleIdentifier)")
		}
	}
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	let xpcConnection = NSXPCConnection(machServiceName: "com.fromconcentratesoftware.Bridge", options: [])
	let listener = NSXPCListener.anonymous()
	let listenerDelegate: ClientListenerDelegate

	override init() {
		let client = Client()
		listenerDelegate = ClientListenerDelegate(client: client)
		listener.delegate = listenerDelegate
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		activateLoginItems(from: Bundle.main, using: FileManager.default)

		listener.resume()

		xpcConnection.remoteObjectInterface = NSXPCInterface(with: CommunicationServer.self)
		xpcConnection.resume()
		(xpcConnection.remoteObjectProxy as? CommunicationServer)?.register(client: listener.endpoint)
	}

}

