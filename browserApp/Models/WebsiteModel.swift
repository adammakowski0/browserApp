//
//  BrowserModel.swift
//  browserApp
//
//  Created by Adam Makowski on 20/08/2024.
//

import Foundation
import SwiftUI

struct WebsiteModel: Identifiable {
    let id: UUID
    let url: String
    let title: String
    let image: UIImage?
    let hostURL: String
    let date: Date
    
    init(id: UUID = UUID(), url: String, title: String, image: UIImage?, host: String, date: Date = .now) {
        self.id = id
        self.url = url
        self.title = title
        self.image = image
        self.hostURL = host
        self.date = date
        
    }
}
