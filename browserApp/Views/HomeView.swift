//
//  ContentView.swift
//  browserApp
//
//  Created by Adam Makowski on 01/08/2024.
//

import SwiftUI
import WebKit

struct HomeView: View {
    
    @EnvironmentObject var vm: BrowserViewModel
    
    @FocusState var searchBarFocused: Bool
    
    @State var showOptions = false
    
    var body: some View {
        
        ZStack (alignment: .bottom){
            
            Color("backgroundColor").ignoresSafeArea()
            
            webView
            
                .sheet(isPresented: $vm.showSettingsView, content: {
                    SheetView()
                        .presentationDetents([.fraction(0.7), .fraction(0.99)])
                        .presentationBackground(.thinMaterial)
                        .presentationCornerRadius(30)
                })
                .onAppear{
                    vm.loadURL()
                }
        }
    }
}

extension HomeView {
    private var webView: some View {
        VStack {
            vm.webView
                .cornerRadius(8)
                .overlay(alignment: .top, content: {
                    if vm.isLoading{
                        ProgressView(value: vm.loadingProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.blue)
                            .opacity(0.8)
                    }
                })
                .overlay(alignment: .bottom) {
                    if !vm.isToolbarHidden{
                        bottomBar
                            .transition(.move(edge: .bottom))
                    }
                }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var bottomBar: some View {
        
        
        ZStack(alignment: .bottomLeading) {
            if showOptions{
                MenuButtonView(
                    showMenu: $vm.showSettingsView,
                    showOptions: $showOptions,
                    sharedURL: vm.websiteURL)
                .frame(maxWidth: 0, alignment: .bottomLeading)
                .zIndex(1.0)
                .offset(x: 0, y: -65)
                .padding()
                .transition(.scale)
                
            }
            ZStack{
                
                Color(.clear)
                    .background(.thinMaterial)
                    .cornerRadius(50)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                
                HStack {
                    
                    Button(action: {
                        withAnimation {
                            showOptions.toggle()
                        }
                        
                        
                    }, label: {
                        Image(systemName: "arrow.up")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(.thinMaterial)
                                    .shadow(radius: 5)
                            )
                            .rotationEffect(Angle(
                                degrees: showOptions ? -180 : 0))
                    })
                    .padding(.leading)
                    
                    TextField("\(Image(systemName: "magnifyingglass")) Search", text: searchBarFocused ? $vm.websiteURL : $vm.urlHost)
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
                            vm.loadURL()
                            searchBarFocused = false
                        }
                        .padding(.trailing, searchBarFocused ? 0 : 20)
                    
                    if searchBarFocused{
                        Button(action: {vm.websiteURL = ""}, label: {
                            Image(systemName: "x.circle.fill")
                                .font(.title3)
                                .tint(.primary)
                        })
                        .transition(AnyTransition.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0.1).delay(0.25)), removal: .opacity.animation(.easeInOut(duration: 0.01))))
                        .padding(.trailing)
                    }
                }
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 20)
            .frame(height: 100)
            
        }
        .animation(.easeInOut(duration: 0.3), value: searchBarFocused)
        .offset(y: searchBarFocused ? -330 : 0)

        
    }
}



#Preview {
    HomeView()
        .environmentObject(BrowserViewModel())
}
