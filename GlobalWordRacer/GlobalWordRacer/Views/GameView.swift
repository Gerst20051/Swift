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

    var body: some View {
        VStack {
            TitleView(title: "Global Word Racer")
            Spacer()
            buildBoard()
            CurrentSelectionView(text: $currentSelection, handler: selectionHandler)
            InvalidWordView(word: $invalidWord, duplicate: $duplicateWord)
            FoundSolutionsView(list: $foundSolutions)
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
                                LetterView(text: self.$grid[rowIndex][cellIndex], handler: self.letterHandler)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
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
        ]), solutions: .constant([]))
    }

}
