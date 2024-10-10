//
//  MenuButtonView.swift
//  browserApp
//
//  Created by Adam Makowski on 02/10/2024.
//

import SwiftUI

struct MenuButtonView: View {
    @Binding var showMenu: Bool
    @Binding var showOptions: Bool
    var sharedURL: String
    
    var body: some View {
            VStack(alignment: .leading, spacing: 15){
                Button {
                    showMenu = true
                    showOptions = false
                } label: {
                    Text("Menu")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .tint(.primary)
                        .padding()
                        .padding(.horizontal)
                        .frame(width: 160)
//                        .background(
//                            RoundedRectangle(cornerRadius: 20)
//                                .fill(.thinMaterial)
//                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
//                        )
                        .background()
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                if let url = URL(string: sharedURL) {
                    ShareLink(item: url){
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                        .font(.headline)
                        .fontDesign(.rounded)
                        .tint(.primary)
                        .padding()
                        .padding(.horizontal)
                        .frame(width: 160)
                        .background()
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                    
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(15)
            .shadow(radius: 2)

    }
}

#Preview {
    MenuButtonView(showMenu: .constant(true), showOptions: .constant(true), sharedURL: "www.google.pl")
}
