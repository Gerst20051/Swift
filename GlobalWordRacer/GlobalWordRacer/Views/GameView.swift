//
//  GameView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/16/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import SwiftUI

struct GameView: View {

    @Binding var grid: [[String]]
    @Binding var solutions: [String]
    @State private var currentSelection = ""
    @State private var foundSolutions: [String] = []
    @State private var invalidWord = ""
    @State private var duplicateWord = ""
    @State private var hasRoundEnded = false
    @State private var timeRemaining: Int = 30
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let loadNewGameHandler: (_ callback: @escaping () -> Void) -> Void

    var body: some View {
        VStack {
            Text("Global Word Racer")
                .fontWeight(.semibold)
                .font(.system(size: 40))
                .frame(width: UIScreen.main.bounds.width, height: 60)
                .padding(.top, 80)
                .background(Color.blue)
                .foregroundColor(.white)
            buildBoard()
            CurrentSelectionView(text: $currentSelection, hasRoundEnded: $hasRoundEnded, handler: selectionHandler)
            Text(timeRemaining > 0
                ? "This Round Ends In \(timeRemaining) Seconds"
                : "Next Round Starts In \(16 + timeRemaining) Seconds"
            )
                .padding(.top)
                .foregroundColor(.black)
                .onReceive(gameTimer) { input in
                    self.timeRemaining -= 1
                    if (self.timeRemaining <= 0) {
                        self.hasRoundEnded = true
                        self.currentSelection = ""
                        self.invalidWord = ""
                        self.duplicateWord = ""
                    }
                    if (self.timeRemaining <= -15) {
                        self.loadNewGameHandler({
                            self.timeRemaining = 30
                            self.hasRoundEnded = false
                            self.foundSolutions = []
                        })
                    }
                }
            InvalidWordView(word: $invalidWord, duplicate: $duplicateWord)
            FoundSolutionsView(list: $foundSolutions, solutions: $solutions, hasRoundEnded: $hasRoundEnded)
            Spacer()
        }
    }

    func buildBoard() -> some View {
        VStack(spacing: 20) {
            ForEach(grid.indices) { rowIndex in
                HStack {
                    Group {
                        Spacer()
                        ForEach(self.grid[rowIndex].indices) { cellIndex in
                            Group {
                                LetterView(text: self.$grid[rowIndex][cellIndex], hasRoundEnded: self.$hasRoundEnded, handler: self.letterHandler)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
            .padding(.top, 20)
    }

    func letterHandler(letter: String) -> Void {
        currentSelection += letter
    }

    func selectionHandler() -> Void {
        if (foundSolutions.contains(currentSelection.uppercased())) {
            invalidWord = ""
            duplicateWord = currentSelection.uppercased()
        } else if (solutions.contains(currentSelection.uppercased())) {
            invalidWord = ""
            duplicateWord = ""
            foundSolutions.append(currentSelection.uppercased())
        } else {
            invalidWord = currentSelection.uppercased()
            duplicateWord = ""
        }
        currentSelection = ""
    }

}

struct GameView_Previews: PreviewProvider {

    static var previews: some View {
        GameView(grid: .constant([
            ["A", "B", "C", "D"],
            ["E", "Qu", "G", "H"],
            ["I", "J", "K", "L"],
            ["M", "N", "O", "P"]
        ]), solutions: .constant([]), loadNewGameHandler: { callback in })
    }

}
