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
            buildBoard(grid)
        }
    }

    func buildBoard(_ board: [[String]]) -> some View {
        VStack(spacing: 5) {
            ForEach(board, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(row, id: \.self) { cell in
                        Text(cell)
                    }
                }
            }
        }
    }

}

struct GameView_Previews: PreviewProvider {

    static var previews: some View {
        GameView(grid: .constant([]), solutions: .constant([]))
    }

}
