//
//  DecryptionViewController.swift
//  OnlyTestADHASH
//
//  Created by Dima Senchik on 9/29/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

protocol DecryptionDelegate: AnyObject {
	func didGetDecrypted(content: String)
}

final class DecryptionViewController: UIViewController, WKScriptMessageHandler {
	
	//MARK: - Outlets
	private var webView = WKWebView()
	
	//MARK: - Properties
	var delegate: DecryptionDelegate!
	var encryptedURL: String!
	var decryptKey: String!
	
	//MARK: - Life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		view.isOpaque = false
		view.backgroundColor = .clear
		webView.backgroundColor = .clear
		configureWebView()
	}
	
	deinit {
		print("was deinited")
	}
	
	//MARK: - Private methods
	private func configureWebView() {
		webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		let bundleURL = Bundle(for: type(of: self)).resourceURL!.absoluteURL
		let htmlFile = bundleURL.appendingPathComponent("index.html")
		do {
			let htmlString = try String(contentsOf: htmlFile) +
			"""
			</script>
			<script type="text/javascript">
			let encrypted = "\(encryptedURL!)";
			let key = "\(decryptKey!)";
			
			document.addEventListener("DOMContentLoaded", function() {
			let url = decrypt(encrypted, key);
			let text = "DECRYPTED: " + url;
			document.querySelector('body').innerText = text;
			console.log(text);
			window.webkit.messageHandlers.jsHandler.postMessage(url);
			});
			
			</script>
			</html>
			"""
			webView.configuration.userContentController.add(self, name: "jsHandler")
			webView.loadHTMLString(htmlString, baseURL: nil)
			view.addSubview(webView)
		} catch {
			print("error parsing")
		}
	}
	
	//MARK: - WKScriptMessageHandler
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		if message.name == "jsHandler" {
			delegate.didGetDecrypted(content: message.body as! String)
			dismiss(animated: false, completion: nil)
        }
	}
	
}
