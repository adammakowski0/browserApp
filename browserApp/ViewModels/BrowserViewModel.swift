//
//  BrowserViewModel.swift
//  browserApp
//
//  Created by Adam Makowski on 19/08/2024.
//

import Foundation
import SwiftUI
import WebKit
import CoreData

class BrowserViewModel: ObservableObject{
    
    let container: NSPersistentContainer
    
    @Published var webView = WebView()
    
    @Published var websitesHistoryList: [WebsiteModel] = []
    
    @Published var savedEntities: [WebsiteEntity] = []
    
    @Published var isLoading = false
    
    @Published var loadingProgress = 0.0
    
    @Published var isToolbarHidden = false
    
    @Published var keyboardHeight: CGFloat = 0
    
    @Published var searchBarFocused: Bool = false
    
    @AppStorage("saveHistory") var saveBrowserHistory = true
    @AppStorage("websiteURL") var websiteURL = "https://www.google.com/"
    @AppStorage("urlHost") var urlHost = "www.google.pl"
    
    init(){
        container = NSPersistentContainer(name: "BrowserContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading core data. \(error)")
            }
        }
        fetchData()
    }

    func fetchData(){
        let request = NSFetchRequest<WebsiteEntity>(entityName: "WebsiteEntity")
        do{
            savedEntities = try container.viewContext.fetch(request)
            for entity in savedEntities{
                addToHistory(url: entity.url ?? "",
                             title: entity.title ?? "",
                             image: nil,
                             host: entity.urlHost ?? "",
                             entityID: entity.id ?? UUID())
            }
            saveData()
        }
        catch let error {
            print(error)
        }
        
    }
    
    func loadURL() {
        webView.loadURL(urlString: websiteURL)
    }
    
    func goBack() {
        webView.goBack()
        websiteURL = webView.webView.url?.absoluteString ?? ""
    }
    
    func goForward() {
        webView.goForward()
        websiteURL = webView.webView.url?.absoluteString ?? ""
    }
    
    func addToHistory(url: String, title: String, image: UIImage?, host: String, entityID: UUID){
        let website = WebsiteModel(id: entityID, url: url, title: title, image: image, host: host, date: Date())
        if saveBrowserHistory{
            websitesHistoryList.append(website)
            saveData()
        }
    }
    
    func addToHistoryCore(url: String, title: String, host: String, websiteID: UUID){
        if saveBrowserHistory{
            let website = WebsiteEntity(context: container.viewContext)
            website.url = url
            website.title = title
            website.urlHost = host
            website.id = websiteID
            addToHistory(url: url, title: title, image: nil, host: host, entityID: websiteID)
            savedEntities.append(website)
            saveData()
        }
    }
    
    func saveData(){
        do{
            try container.viewContext.save()
        }
        catch let error{
            print(error)
        }
    }

    func deleteFromHistory(website: WebsiteModel){
        websitesHistoryList.removeAll {$0.id == website.id}
        for entity in savedEntities {
            if entity.id == website.id {
                container.viewContext.delete(entity)
            }
        }
        saveData()
        
    }
    
    func clearHistory(){
        websitesHistoryList.removeAll()
        for entity in savedEntities {
            container.viewContext.delete(entity)
        }
        saveData()
    }
}


struct WebView: UIViewRepresentable {
    
    let webView: WKWebView
    
    @EnvironmentObject var browserViewModel: BrowserViewModel
    
    init() {
        self.webView = WKWebView()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        var parent: WebView
        private var lastOffset: CGFloat = 0.0
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.y
            let scrollDirection = offset - lastOffset
            
            parent.browserViewModel.searchBarFocused = false
            parent.browserViewModel.keyboardHeight = 0
            
            if scrollDirection > 10 {
                withAnimation {
                    parent.browserViewModel.isToolbarHidden = true
                }
            } else if scrollDirection < -2 {
                withAnimation {
                    parent.browserViewModel.isToolbarHidden = false
                }
            }
            lastOffset = offset
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            self.parent.browserViewModel.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.delegate = self
            webView.scrollView.bounces = false
            let title = webView.title ?? "No title"
            let host = webView.url?.host() ?? ""

            if let currentURL = webView.url?.absoluteString {
                DispatchQueue.main.async {
                    self.parent.browserViewModel.urlHost = host
                    self.parent.browserViewModel.websiteURL = currentURL
                    self.parent.browserViewModel.addToHistoryCore(url: currentURL, title: title, host: host, websiteID: UUID())
                }
            }
//            webView.evaluateJavaScript("document.body.style.backgroundColor = 'orange'")
//            webView.evaluateJavaScript("document.body.style.backgroundColor") { (result, error) in
//                if let colorString = result as? String {
//                    self.parent.browserViewModel.backgroundColor = UIColor(hex: colorString) ?? .white
//                    print(self.parent.browserViewModel.backgroundColor)
//                }
//            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.parent.browserViewModel.isLoading = false
            }
            self.parent.browserViewModel.loadingProgress = 1.0
        }
        
        public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            self.parent.browserViewModel.loadingProgress = Double(webView.estimatedProgress)
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func loadURL(urlString: String) {
        guard let url = formatURL(urlString) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func formatURL(_ urlString: String) -> URL? {
        var formattedURLString = urlString
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            formattedURLString = "https://" + urlString
        }
        return URL(string: formattedURLString)
    }
}
