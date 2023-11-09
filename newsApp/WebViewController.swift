//
//  WebViewController.swift
//  newsApp
//
//  Created by bjit on 16/1/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView : WKWebView!
    var destinationUrl: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        self.view = webView
        let request = URLRequest(url: URL(string: destinationUrl! )!)
        webView.load(request)
        // Do any additional setup after loading the view.
    }
}
