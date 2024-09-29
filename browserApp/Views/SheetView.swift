//
//  SheetView.swift
//  browserApp
//
//  Created by Adam Makowski on 21/08/2024.
//

import SwiftUI

struct SheetView: View {
    
    @EnvironmentObject var browserViewModel: BrowserViewModel
    @State var selectedView = 0
    
    var body: some View {
        ZStack{
            
            VStack{
                Picker(selection: $selectedView) {
                    Text("History").tag(0)
                    Text("Settings").tag(1)
                } label: {}
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 25)
                .padding(.horizontal)
                
                if selectedView == 0{
                    HistoryView()
                }
                else if selectedView == 1{
                    SettingsView()
                }
                Spacer()
                
            }
        }
    }
}

#Preview {
    SheetView().environmentObject(BrowserViewModel())
}
