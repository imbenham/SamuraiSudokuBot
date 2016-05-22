//
//  PuzzleDifficulty.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation
func == (lhs:PuzzleDifficulty, rhs:PuzzleDifficulty) -> Bool{
    return lhs.toInt() == rhs.toInt()
}

//let cachableDifficulties: [PuzzleDifficulty] = [.Easy, .Medium, .Hard, .Insane]

private var rawDiffDict: [PuzzleDifficulty:Int] = [.Easy : 860, .Medium: 1000, .Hard: 1300, .Insane: 1460]

enum PuzzleDifficulty: Equatable, Hashable {
    case Easy
    case Medium
    case Hard
    case Insane
    case Custom (Int)
    
    static var minEasyThreshold: Int {
        get {
            return rawDiffDict[.Easy]!
        }
    }
    
    static var maxInsaneThreshold: Int {
        get {
            return rawDiffDict[.Insane]!
        }
    }
    
    var identifier: String {
        get {
            switch self{
            case .Easy:
                return Utils.Constants.Identifiers.easyPuzzleKey
            case .Medium:
                return Utils.Constants.Identifiers.mediumPuzzleKey
            case .Hard:
                return Utils.Constants.Identifiers.hardPuzzleKey
            case .Insane:
                return Utils.Constants.Identifiers.insanePuzzleKey
            default:
                return Utils.Constants.Identifiers.customPuzzleKey
            }
        }
    }
    
    static func fromCacheString(cacheString: String) -> PuzzleDifficulty {
        let dict:[String: PuzzleDifficulty] = [PuzzleDifficulty.Easy.identifier: .Easy, PuzzleDifficulty.Medium.identifier: .Medium, PuzzleDifficulty.Hard.identifier: .Hard, PuzzleDifficulty.Insane.identifier: Insane]
        if let diff = dict[cacheString] {
            return diff
        } else {
            return Custom(0)
        }
    }
    
    var isCachable: Bool {
        switch self{
        case .Custom (_):
            return false
        default:
            return true
        }
    }
    
    var currentKey: String? {
        switch self {
        case .Easy:
            return currentEasyPuzzleKey
        case .Medium:
            return currentMediumPuzzleKey
        case .Hard:
            return currentHardPuzzleKey
        case .Insane:
            return currentInsanePuzzleKey
        default:
            return nil
        }
    }
    
    var hashValue: Int {
        get {
            return self.toInt()
        }
    }
    
    var rawDifficultyThreshold: Int {
        switch self {
        case .Custom(let diff):
            return diff
        default:
            return rawDiffDict[self]!
        }
    }
    
    func toInt() -> Int {
        switch self{
        case .Easy:
            return 0
        case .Medium:
            return 1
        case .Hard:
            return 2
        case .Insane:
            return 3
        case .Custom(let diff):
            return 4 + diff
        }
    }
    
    func stylizedDescriptor(allCaps: Bool = true) -> NSAttributedString {
        let configs = Utils.ButtonConfigs()
        var attributedTitle: NSAttributedString
        switch self {
        case .Easy:
            let string = allCaps ? "EASY" : "Easy"
            attributedTitle = configs.getAttributedBodyText(string)
        case .Medium:
            let string = allCaps ? "MEDIUM" : "Medium"
            attributedTitle = configs.getAttributedBodyText(string)
        case .Hard:
            let string = allCaps ? "HARD" : "Hard"
            attributedTitle = configs.getAttributedBodyText(string)
        case .Insane:
            let string = allCaps ? "INSANE" : "Insane"
            attributedTitle = configs.getAttributedBodyText(string)
        default:
            let string = allCaps ? "CUSTOM" : "Custom"
            attributedTitle = configs.getAttributedTitle(string)
        }
        return attributedTitle
    }
    
}
