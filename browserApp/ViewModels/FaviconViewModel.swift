//
//  FaviconViewModel.swift
//  browserApp
//
//  Created by Adam Makowski on 21/09/2024.
//

import Foundation
import SwiftUI
import Combine


class FaviconViewModel: ObservableObject{
    
    @Published var faviconImage: UIImage? = nil
    
    var faviconUrl: String
    var cancellables = Set<AnyCancellable>()
    var cacheManager = CacheManager.instance
    
    init(url: String) {
        self.faviconUrl = url
        getImage()
    }
    
    func getImage() {
        if let image = cacheManager.get(key: faviconUrl){
            faviconImage = image
        }
        else{
            downloadImage()
        }
    }
    
    func downloadImage(){
        
        guard let faviconURL = URL(string: "https://\(faviconUrl)/favicon.ico") else {return}
        
        URLSession.shared.dataTaskPublisher(for: faviconURL)
            .map { (UIImage(data: $0.data)) }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] image in
                guard
                    let self = self,
                    let image = image
                else {return}
                
                self.faviconImage = image
                self.cacheManager.add(key: self.faviconUrl, value: image)
            }
            .store(in: &cancellables)
    }
}
