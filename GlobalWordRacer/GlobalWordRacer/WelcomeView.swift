//
//  WelcomeView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/16/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {

    @Binding var showGame: Bool

    @State var title = "Global Word Racer"

    var body: some View {
        VStack {
            Text(title)
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: 50
                )
                .background(Color.blue)
                .foregroundColor(Color.white)
                .padding(10)

            Button(
                action: { self.showGame = true },
                label: { Text("Join Game") }
            )
        }
    }

}

struct WelcomeView_Previews: PreviewProvider {

    static var previews: some View {
        WelcomeView(showGame: .constant(false))
    }

}
