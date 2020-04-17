//
//  MainView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/16/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import SwiftUI

struct MainView: View {

    @State var showGame = false
    @State var grid: [[String]] = []
    @State var solutions: [String] = []

    var body: some View {
        Group {
            if showGame {
                GameView(grid: $grid, solutions: $solutions)
            } else {
                WelcomeView(showGame: $showGame, grid: $grid, solutions: $solutions)
            }
        }
    }

}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
