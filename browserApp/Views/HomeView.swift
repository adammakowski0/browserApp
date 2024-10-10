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
                // MARK: Bottom bar background
                Color(.clear)
                    .background(.thinMaterial)
                    .cornerRadius(50)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 4.0)
                
                HStack {
                    
                    menuButton
                    
                    urlTextField
                    
                    refreshButton
                    
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
    
    private var menuButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                vm.showOptions.toggle()
            }
            
        }, label: {
            Image(systemName: "ellipsis")
                .font(.headline)
                .fontWeight(.black)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .padding(12)
                .background(
                    Circle()
                        .fill(.regularMaterial)
                        .shadow(radius: 5)
                )
                .bounceAnimation(value: $vm.showOptions)
        })
        .padding(.leading)
    }
    
    private var urlTextField: some View {
        TextField("\(Image(systemName: "magnifyingglass")) Search", text: searchBarFocused ? $vm.websiteURL : $vm.urlHost)
            .foregroundStyle(.primary)
            .font(.headline)
            .multilineTextAlignment(searchBarFocused ? .leading : .center)
            .focused($searchBarFocused)
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("textFieldBackgroundColor"))
                    .shadow(radius: 5)
            )
            .submitLabel(.search)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .onSubmit {
                vm.loadURL()
                searchBarFocused = false
            }
            .padding(.trailing,
                     vm.keyboardHeight >= 0 || searchBarFocused ? 10 : 0)
    }
    
    private var refreshButton: some View {
        Button {
            vm.refreshButtonAction()
        } label: {
            Image(systemName: vm.keyboardHeight > 0 || searchBarFocused ?
                  "xmark" : "arrow.clockwise")
            .font(.headline)
            .fontDesign(.rounded)
            .foregroundColor(.primary)
            .padding(7)
            .background(
                Circle()
                    .fill(.regularMaterial)
                    .shadow(radius: 5)
            )
            .rotationEffect(Angle(degrees: vm.refresh ? 360 : 0))
            .replaceTransition()
        }
        .padding(.trailing)
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

struct menuButtonAnimation: ViewModifier {
    
    @Binding var value: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .symbolEffect(.bounce.down.byLayer, value: value)
        }
        else {
            content
        }
    }
}

struct BounceViewModifier: ViewModifier {
    
    @Binding var value: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .symbolEffect(.bounce.down.byLayer, value: value)
        }
        else {
            content
        }
    }
}

struct ReplaceViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .contentTransition(.symbolEffect(.replace))
        }
        else {
            content
        }
    }
}


public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state))
    }
    func bounceAnimation(value: Binding<Bool>) -> some View {
        self.modifier(BounceViewModifier(value: value))
    }
    func replaceTransition() -> some View {
        self.modifier(ReplaceViewModifier())
    }
}

#Preview {
    HomeView()
        .environmentObject(BrowserViewModel())
}
