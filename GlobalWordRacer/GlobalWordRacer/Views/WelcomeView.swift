//
//  WelcomeView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/16/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import Alamofire
import SwiftUI

struct WelcomeView: View {

    @Binding var showGame: Bool
    @Binding var grid: [[String]]
    @Binding var solutions: [String]

    var body: some View {
        VStack {
            TitleView(title: "Global Word Racer")

            Button(
                action: {
                    AF.request("http://hnswave.co:8000/grid")
                        .validate()
                        .responseDecodable(of: GridAndSolutions.self) { response in
                            guard let data = response.value else { return }
                            self.grid = data.grid
                            self.solutions = data.solutions
                            self.showGame = true
                        }
                },
                label: {
                    Text("Join Game")
                        .font(.system(size: 40))
                }
            )
                .padding(40)
        }
    }

}

struct WelcomeView_Previews: PreviewProvider {

    static var previews: some View {
        WelcomeView(showGame: .constant(false), grid: .constant([]), solutions: .constant([]))
    }

}
