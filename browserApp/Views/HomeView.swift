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
    
    var body: some View {
        
        ZStack (alignment: .bottom){
            
            Color("backgroundColor").ignoresSafeArea()
            
            webView
                .sheet(isPresented: $vm.showMenu, content: {
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
                            .padding(.bottom, 5)
                            .frame(maxWidth: 700) // for iPad
                    }
                }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var bottomBar: some View {
        ZStack(alignment: .bottomLeading) {
            if vm.showOptions{
                MenuButtonView(
                    showMenu: $vm.showMenu,
                    showOptions: $vm.showOptions,
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
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.showOptions.toggle()
                        }
                        
                    }, label: {
                        Image(systemName: "arrow.up")
                            .font(.title3)
                            .fontWeight(.black)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(.thinMaterial)
                                    .shadow(radius: 5)
                            )
                            .rotationEffect(Angle(
                                degrees: vm.showOptions ? -180 : 0))
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
                        .padding(.trailing,
                                 vm.keyboardHeight >= 0 || searchBarFocused ? 10 : 0)
                    
                    if vm.keyboardHeight > 0 || searchBarFocused{
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
            .onAppear { searchBarFocused = vm.searchBarFocused }
            .onChange(of: searchBarFocused) { vm.searchBarFocused = $0 }
            .onChange(of: vm.searchBarFocused) { searchBarFocused = $0 }
            .padding(.vertical, 25)
            .padding(.horizontal, 20)
            .frame(height: 100)
        }
        .keyboardHeight($vm.keyboardHeight)
        .animation(.easeInOut(duration: 0.2), value: vm.keyboardHeight)
        .offset(y: -vm.keyboardHeight)
    }
}

struct KeyboardProvider: ViewModifier {
    
    var keyboardHeight: Binding<CGFloat>
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                       perform: { notification in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
                self.keyboardHeight.wrappedValue = keyboardRect.height
                
            }).onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                         perform: { _ in
                self.keyboardHeight.wrappedValue = 0
            })
    }
}


public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state))
    }
}

#Preview {
    HomeView()
        .environmentObject(BrowserViewModel())
}
