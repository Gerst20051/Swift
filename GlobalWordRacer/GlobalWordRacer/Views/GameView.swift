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

    var body: some View {
        VStack {
            Text("Global Word Racer")
            Spacer()
            buildBoard()
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
                                LetterView(text: self.$grid[rowIndex][cellIndex])
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
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
