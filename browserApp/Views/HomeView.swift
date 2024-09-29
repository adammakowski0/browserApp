//
//  ContentView.swift
//  browserApp
//
//  Created by Adam Makowski on 01/08/2024.
//

import SwiftUI
import WebKit

struct HomeView: View {
    
    @EnvironmentObject var browserViewModel: BrowserViewModel
    
    @FocusState var searchBarFocused: Bool
    
    var body: some View {
        
        ZStack (alignment: .bottom){
            
            Color("backgroundColor").ignoresSafeArea()
            
            webView
            
            .sheet(isPresented: $browserViewModel.showSettingsView, content: {
                SheetView()
                    .presentationDetents([.fraction(0.7), .fraction(0.99)])
                    .presentationBackground(.thinMaterial)
                    .presentationCornerRadius(30)
            })
            .onAppear{
                browserViewModel.loadURL()
            }
        }
    }
}

extension HomeView {
    private var webView: some View {
        VStack {
            browserViewModel.webView
                .cornerRadius(8)
                .overlay(alignment: .top, content: {
                    if browserViewModel.isLoading{
                        ProgressView(value: browserViewModel.loadingProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.blue)
                            .opacity(0.8)
                    }
                })
                .overlay(alignment: .bottom) {
                    bottomBar
                }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var bottomBar: some View {
        ZStack {
            Color(.clear)
                .background(.thinMaterial)
                .cornerRadius(50)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                
                
            HStack {
                Button(action: {
                    browserViewModel.showSettingsView.toggle()
                    
                }, label: {
                    Image(systemName: "globe")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                })
                .padding(.leading)
                
                
                TextField("\(Image(systemName: "magnifyingglass")) Search", text: searchBarFocused ? $browserViewModel.websiteURL : $browserViewModel.urlHost)
                    .foregroundStyle(.primary)
                    .font(.headline)
                    .multilineTextAlignment(searchBarFocused ? .leading : .center)
                    .focused($searchBarFocused)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("textFieldBackgroundColor")))
                    .shadow(radius: 10)
                    .submitLabel(.search)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onSubmit {
                        browserViewModel.loadURL()
                        searchBarFocused = false
                    }
                    .padding(.trailing, searchBarFocused ? 0 : 20)

                if searchBarFocused{
                    Button(action: {browserViewModel.websiteURL = ""}, label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.black)
                    })
                    .transition(AnyTransition.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0.1).delay(0.25)), removal: .opacity.animation(.easeInOut(duration: 0.01))))
                    .padding(.trailing)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: searchBarFocused)
        .offset(y: searchBarFocused ? -330 : 0)
        .padding(.vertical, 25)
        .padding(.horizontal, 20)
        .frame(height: 100)
    }
}



#Preview {
    HomeView()
        .environmentObject(BrowserViewModel())
}
