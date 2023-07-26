//
//  ViewController.swift
//  FlippedCardsGame
//
//  Created by Mert Can Bilgin on 26.07.2023.
//

import UIKit

extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        return first { $0.1 == value }?.0
    }
}

class ViewController: UICollectionViewController {
    var cards = [Card]()
    
    var countries = ["china", "france", "india", "italy", "turkey", "uae"]
    var countriesStructures = ["greatWall", "eiffelTower", "tajMahal", "pisaTower", "ayasofya", "burjKhalifa"]
    
    var matches = ["china": "greatWall", "france": "eiffelTower", "india": "tajMahal", "italy": "pisaTower", "turkey": "ayasofya", "uae": "burjKhalifa"]
    
    var selectedCards = [Card]()
    
    var score = 0 {
        didSet {
            title = "Score: \(score)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        score = 0

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(newGame))
        
        loadCards()
    }
    
    func loadCards() {
        for country in countries {
            let card = Card(name: country, image: UIImage(named: country)!)
            cards.append(card)
        }
        
        for countryStructure in countriesStructures {
            let card = Card(name: countryStructure, image: UIImage(named: countryStructure)!)
            cards.append(card)
        }
        
        cards.shuffle()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count + countriesStructures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as? CardCell else { fatalError("Unable to dequeue CardCell") }
        
        if cards[indexPath.item].isFlipped == false {
            cell.imageView.image = UIImage(named: "backFace")
        } else {
            if cards[indexPath.item].isRemoved {
                cell.imageView.image = cards[indexPath.item].image
                cell.imageView.isUserInteractionEnabled = false
                cell.imageView.alpha = 0.1
            } else {
                cell.imageView.image = cards[indexPath.item].image
            }
        }
        
        cards[indexPath.item].indexPath = indexPath
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cards[indexPath.item].isFlipped == true {
            if let index = selectedCards.firstIndex(of: cards[indexPath.item]) {
                selectedCards.remove(at: index)
            }
            cards[indexPath.item].isFlipped = false
            animateCard(index: indexPath, img: UIImage(named: "backFace")!)
        } else {
            selectedCards.append(cards[indexPath.item])
            cards[indexPath.item].isFlipped = true
            animateCard(index: indexPath, img: cards[indexPath.item].image)
        }
                
        if selectedCards.count == 2 {
            checkMatch()
        } else if selectedCards.count > 2 {
            for selectedCard in selectedCards {
                animateCard(index: selectedCard.indexPath!, img: UIImage(named: "backFace")!)
                cards[selectedCard.indexPath!.item].isFlipped = false
            }
            selectedCards.removeAll()
            score -= 1
        }
    }
    
    func animateCard(index: IndexPath, img: UIImage) {
        if let cell = collectionView.cellForItem(at: index) as? CardCell {
            UIView.transition(with: cell.imageView, duration: 0.75, options: .transitionFlipFromRight) {
                cell.imageView.image = img
            }
        }
    }
    
    func checkMatch() {
        if matches[selectedCards[0].name] == selectedCards[1].name {
            removeCards()
            score += 1
        } else if matches.key(forValue: selectedCards[0].name) == selectedCards[1].name {
            removeCards()
            score += 1
        } else {
            score -= 1
        }
        
        checkGameOver()
    }
    
    func animateCardForRemoving(index: IndexPath) {
        if let cell = collectionView.cellForItem(at: index) as? CardCell {
            cell.isUserInteractionEnabled = false
            UIView.transition(with: cell.imageView, duration: 0.50) {
                cell.alpha = 0.1
            }
        }
    }
    
    func removeCards() {
        for selectedCard in selectedCards {
            animateCardForRemoving(index: selectedCard.indexPath!)
            cards[selectedCard.indexPath!.item].isRemoved = true
        }

        selectedCards.removeAll()
    }
    
    func checkGameOver() {
        for card in cards {
            if !card.isFlipped {
                return
            }
        }
        
        let ac = UIAlertController(title: "Game Over!", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Play again!", style: .default) { _ in
            self.newGame()
        })
        ac.addAction(UIAlertAction(title: "Share my score", style: .default) {_ in
            self.shareScore()
        })
        present(ac, animated: true)
        
    }
    
    @objc func newGame() {
        score = 0
        cards.removeAll()
        selectedCards.removeAll()
        loadCards()
        collectionView.reloadData()
    }
    
    @objc func shareScore() {
        guard let image = UIImage(named: "score") else {
            print("No image found")
            return
        }
        
        let imageSize = image.size
        let scale = image.scale
        let text = "My Score is \(score)!"
        let font = UIFont.systemFont(ofSize: 64)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        image.draw(at: CGPoint.zero)
        
        // Calculate the size of the text and its position to center it on the image
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        let textSize = (text as NSString).size(withAttributes: textAttributes)
        let textX = (imageSize.width - textSize.width) / 2
        let textY = (imageSize.height - textSize.height) / 2
        
        (text as NSString).draw(at: CGPoint(x: textX, y: textY), withAttributes: textAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let updatedImage = newImage {
            let vc = UIActivityViewController(activityItems: [updatedImage.jpegData(compressionQuality: 0.8) as Any], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(vc, animated: true)
        }
    }

}

