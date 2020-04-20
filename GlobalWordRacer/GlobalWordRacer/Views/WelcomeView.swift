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
    let loadNewGameHandler: (_ callback: @escaping () -> Void) -> Void

    var body: some View {
        VStack {
            Spacer()

            Text("Global Word Racer")
                .fontWeight(.semibold)
                .font(.system(size: 40))
                .frame(width: UIScreen.main.bounds.width, height: 140)
                .background(Color.blue)
                .foregroundColor(.white)

            Button(
                action: {
                    self.loadNewGameHandler({})
                },
                label: {
                    Text("Join Game")
                        .font(.system(size: 40))
                }
            )
                .padding(40)

            Spacer()
        }
    }

}

struct WelcomeView_Previews: PreviewProvider {

    static var previews: some View {
        WelcomeView(showGame: .constant(false), loadNewGameHandler: { callback in })
    }

}
