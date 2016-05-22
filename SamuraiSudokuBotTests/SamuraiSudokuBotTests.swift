//
//  SamuraiSudokuBotTests.swift
//  SamuraiSudokuBotTests
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import XCTest
@testable import SamuraiSudokuBot

var matrix = SamuraiMatrix()

class SamuraiSudokuBotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPuzzleScores() {
        // this test produces a benchmark difficulty for the hardest level of puzzle
        
        if let easyPuzzle = getTestPuzzOfDifficulty("EasyPuzzle") {
            let easyScore = matrix.scorePuzzle(easyPuzzle)
            
            print("easy score: \(easyScore)")
            
            XCTAssert(easyScore > 0)
            
            matrix = SamuraiMatrix()
            
            if let medPuzz = getTestPuzzOfDifficulty("MediumPuzzle"){
                let medScore = matrix.scorePuzzle(medPuzz)
                
                print("medium score: \(medScore)")
                
                XCTAssert(medScore > easyScore)
                
                matrix = SamuraiMatrix()
                
                if let hardPuzz = getTestPuzzOfDifficulty("HardPuzzle"){
                    let hardScore = matrix.scorePuzzle(hardPuzz)
                    
                    print("hard score: \(hardScore)")
                    
                    XCTAssert(hardScore > medScore)
                    
                    matrix = SamuraiMatrix()
                    
                    if let insanePuzz = getTestPuzzOfDifficulty("InsanePuzzle") {
                        let insaneScore = matrix.scorePuzzle(insanePuzz)
                        
                        print("insane score: \(insaneScore)")
                        
                        XCTAssert(insaneScore > hardScore)
                        
                    }
                }
                
            }

        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    // helper functions
    
    func getTestPuzzOfDifficulty(diff: String) -> [PuzzleCell]? {
        
        let bundle = NSBundle(forClass: SamuraiSudokuBotTests.self)
        
        guard let pListPath = bundle.pathForResource("TestPuzzles", ofType: "plist") else {
            print("couldn't get path to puzzle list")
            return nil
        }
        
        let pList = NSDictionary(contentsOfFile: pListPath)!
        
        guard let insanePuzzle = pList[diff] as? [String: [[NSNumber]]], let b1 = insanePuzzle["Board1"], let b2 = insanePuzzle["Board2"], let b3 = insanePuzzle["Board3"],let b4 = insanePuzzle["Board4"], let b0 = insanePuzzle["Board0"] else {
            print("downcast failed")
            return nil
        }
        
        
        var cells: [PuzzleCell] = []
        
        for (boardNumber, board) in [b0, b1, b2, b3, b4].enumerate() {
            
            let board = board.map({$0.map({$0.integerValue}).filter({$0 > 0})})
            
            for (boxIndex, box) in board.enumerate() {
                for (tile, value) in box.enumerate() {
                    let tileIndex = TileIndex(boxIndex, tile)
                    let cell = PuzzleCell(tileIndex: tileIndex, value: value, boardIndex: boardNumber)
                    cells.append(cell)
                }
            }
        }
        
        return cells
    }
    
}
