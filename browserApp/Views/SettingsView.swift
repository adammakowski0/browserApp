//
//  SettingsView.swift
//  browserApp
//
//  Created by Adam Makowski on 21/08/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var browserViewModel: BrowserViewModel
    @State var selectedView = 0
    
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack{
            
            VStack{
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 10)
                Toggle("Browsing history", isOn: $browserViewModel.saveBrowserHistory)
                    .padding(.horizontal, 25)
                    .padding(.bottom)
                Button(action: { showAlert.toggle() },
                       label: {
                    Text("Clear history")
                        .tint(.primary)
                        .font(.headline)
                        .padding()
                        .padding(.horizontal)
                        .background(.regularMaterial)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Do you want to delete browsing history?"),
                          primaryButton: .destructive(Text("Delete"),
                                                      action: browserViewModel.clearHistory),
                          secondaryButton: .cancel())
                }
            }
        }
    }
}

#Preview {
    SettingsView().environmentObject(BrowserViewModel())
}
