//
//  FaviconView.swift
//  browserApp
//
//  Created by Adam Makowski on 21/09/2024.
//

import Foundation
import SwiftUI

struct faviconView : View {
    
    @StateObject var vm: FaviconViewModel
    
    init(url: String) {
        _vm = StateObject(wrappedValue: FaviconViewModel(url: url))
    }
    
    var body: some View {
        ZStack{
            if let image = vm.faviconImage{
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(5)
                    .padding(.trailing, 10)
            }
            else{
                Image(systemName: "globe")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(5)
                    .padding(.trailing, 10)
            }
        }
    }
}
