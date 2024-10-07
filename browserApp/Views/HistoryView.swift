//
//  HistoryView.swift
//  browserApp
//
//  Created by Adam Makowski on 21/08/2024.
//

import SwiftUI
import Combine
import WebKit

struct HistoryView: View {
    
    @EnvironmentObject var browserViewModel: BrowserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            VStack{
                Text("History")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 10)
                List{
                    ForEach(browserViewModel.websitesHistoryList.reversed()) { website in
                        HStack {
                            faviconView(url: website.hostURL)
                            
                            VStack {
                                Text(website.title)
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(2)
                                
                                Text(website.url)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.bottom, 15)
                            
                        }.onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                            browserViewModel.websiteURL = website.url
                            browserViewModel.loadURL()
                        }
                        .contextMenu {
                            Button(role: .destructive) {browserViewModel.deleteFromHistory(website: website)} label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        } preview: {
                            if let url = URL(string: website.url) {
                                WebPreview(url: url)
                            }
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct WebPreview: UIViewRepresentable {
    
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

#Preview {
    HistoryView().environmentObject(BrowserViewModel())
}
