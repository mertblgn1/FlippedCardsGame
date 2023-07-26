//
//  Card.swift
//  FlippedCardsGame
//
//  Created by Mert Can Bilgin on 26.07.2023.
//

import UIKit

class Card: NSObject {
    var name: String
    var image: UIImage
    var isFlipped = false
    var indexPath: IndexPath?
    var isRemoved = false
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
}
