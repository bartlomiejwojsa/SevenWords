//
//  ViewController.swift
//  SevenWords
//
//  Created by Bartłomiej Wojsa on 15/01/2023.
//

import UIKit

class ViewController: UIViewController {
    
    let charList = [
        "A","B","C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
        "M", "N", "O", "P","Q", "R", "S", "T", "U", "V", "W", "X",
        "Y", "Z","Ą","Ć","Ę", "Ń", "Ó", "Ś", "Ź","Ż","Ł"
    ]
    
    @IBOutlet var Cards_1R1C: UILabel!
    @IBOutlet var Cards_1R2C: UILabel!
    @IBOutlet var Cards_1R3C: UILabel!
    @IBOutlet var Cards_1R4C: UILabel!
    
    
    @IBOutlet var Cards_2R1C: UILabel!
    @IBOutlet var Cards_2R2C: UILabel!
    @IBOutlet var Cards_2R3C: UILabel!
    @IBOutlet var Cards_2R4C: UILabel!
    
    
    @IBOutlet var currentWord: UITextField!
    
    var slots = [Slot]()
    var onGameStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.assignCardsOnDefault()
    }
    
    func assignCardsOnDefault() {
        slots = [
            Slot(id: 1, elementLabel: Cards_1R1C, points: 5, xposition: 0, yposition: 0),
            Slot(id: 2, elementLabel: Cards_2R1C, points: 5,  xposition: 0, yposition: 1),
            Slot(id: 3, elementLabel: Cards_1R2C, points: 4,  xposition: 1, yposition: 0),
            Slot(id: 4, elementLabel: Cards_2R2C, points: 4, xposition: 1, yposition: 1),
            Slot(id: 5, elementLabel: Cards_1R3C, points: 3,  xposition: 2, yposition: 0),
            Slot(id: 6, elementLabel: Cards_2R3C, points: 3,  xposition: 2, yposition: 1),
            Slot(id: 7, elementLabel: Cards_1R4C, points: 2,  xposition: 3, yposition: 0),
            Slot(id: 8, elementLabel: Cards_2R4C, points: 2,  xposition: 3, yposition: 1)
        ]
    }

    @IBOutlet var countWordButton: UIButton!
    
    @IBOutlet var shuffleButton: UIButton!
    
    
    @IBAction func onNextRound(_ sender: UIButton) {
        self.shuffleToNextRound()
        self.onGameStarted = true
    }
    
    @IBAction func onCountWordResult(_ sender: UIButton) {
        var result = 0
        if let safeWordText = currentWord.text, !safeWordText.isEmpty {
            var usedSlotsIds = [Int]()
            safeWordText.forEach { letter in
                var letterFound = false
                slots.forEach { slot in
                    if  usedSlotsIds.first(where: { slotId in
                        slotId == slot.id
                    }) == nil
                            && letter.uppercased() == (slot.card?.letter ?? "-")
                            && !letterFound {
                        result = result + slot.result
                        usedSlotsIds.append(slot.id)
                        letterFound = true
                    }
                    
                }
            }
            blinkCountedSlots(ids: usedSlotsIds)
        }
        self.countWordButton.setTitle("Get result (last result = \(result))", for: .normal)
    }
    
    func blinkCountedSlots(ids: [Int]) {
        self.slots.enumerated().forEach { (idx, slot) in
            if ids.contains(slot.id) {
                let slotLabel = slot.elementLabel
                let prevColor = slotLabel.textColor
                self.slots[idx].elementLabel.textColor = .systemGreen
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                    self.slots[idx].elementLabel.textColor = prevColor
                }
            }
        }
        
    }
    
    func shuffleToNextRound() {
        if !self.onGameStarted {
            self.initShuffle()
        } else {
            self.nextShuffle()
        }
        self.renderCards()
    }
    
    func renderCards() {
        slots.forEach { slot in
            let slotLabel = slot.elementLabel
            slotLabel.text = slot.card?.letter ?? "?"
        }
    }
    
    func initShuffle() {
        var i = 0
        slots.forEach { slot in
            slots[i].card = Card(id: charList.randomElement()!, letter: charList.randomElement()!)
            i = i + 1
        }
    }
    
    func nextShuffle() {
        // move 2 first xpositions to right by 2, gen new values for them
        let firstRowCards = self.slots.filter { slot in
            slot.yposition == 0
        }
        shiftRow(slotsArr: firstRowCards)

        
        let secondRowCards = self.slots.filter { slot in
            slot.yposition == 1
        }
        shiftRow(slotsArr: secondRowCards)
    
    }
    
    func shiftRow(slotsArr: [Slot]) {
        slotsArr.forEach { slot in
            if [0,1].contains(slot.xposition) {
                if let safeMoveToSlot = slotsArr.first(where: { moveToSlot in
                    moveToSlot.xposition == slot.xposition + 2
                }) {
                    self.slots.enumerated().forEach { (i, moveSlotIter) in
                        if moveSlotIter.id == safeMoveToSlot.id {
                            self.slots[i].card = slot.card
                        }
                    }
                }
                self.slots.enumerated().forEach { (i, iterSlot) in
                    if slot.id == iterSlot.id {
                        self.slots[i].card = Card(id: charList.randomElement()!, letter: charList.randomElement()!)
                    }
                }

            }
        }
    }
    
}

struct Slot {
    let id: Int
    let elementLabel: UILabel
    var card: Card?
    let points: Int
    var result: Int {
        points + (card?.extraPoints ?? 0)
    }
    let xposition: Int
    let yposition: Int
}

struct Card {
    var id: String
    var letter: String
    var extraPoints: Int = 0
}

