//
//  MainView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/16/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import Alamofire
import SwiftUI

struct MainView: View {

    @State var showGame = false
    @State var grid: [[String]] = []
    @State var solutions: [String] = []

    var body: some View {
        Group {
            if showGame {
                GameView(grid: $grid, solutions: $solutions, loadNewGameHandler: loadNewGame)
            } else {
                WelcomeView(showGame: $showGame, loadNewGameHandler: loadNewGame)
            }
        }
            .edgesIgnoringSafeArea(.all)
            .background(Color.white)
    }

    func loadNewGame(callback: @escaping () -> Void) {
        AF.request("http://hnswave.co:8000/grid")
            .validate()
            .responseDecodable(of: GridAndSolutions.self) { response in
                guard let data = response.value else { return }
                self.grid = data.grid
                self.solutions = data.solutions
                self.showGame = true
                callback()
            }
    }

}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
