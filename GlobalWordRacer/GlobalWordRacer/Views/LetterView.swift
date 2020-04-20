//
//  LetterView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/18/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import SwiftUI

struct LetterView: View {

    @Binding var text: String
    @Binding var hasRoundEnded: Bool
    let handler: (String) -> Void

    var body: some View {
        Button(action: {
            self.handler(self.text)
        }) {
            Text(text)
                .fontWeight(.semibold)
                .font(.title)
                .frame(width: 40)
                .padding()
                .background(hasRoundEnded ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(40)
        }
            .disabled(hasRoundEnded)
    }

}

struct LetterView_Previews: PreviewProvider {

    static var previews: some View {
        VStack(spacing: 20) {
            LetterView(text: .constant("A"), hasRoundEnded: .constant(false), handler: { (letter: String) in })
            LetterView(text: .constant("Qu"), hasRoundEnded: .constant(false), handler: { (letter: String) in })
            LetterView(text: .constant("Z"), hasRoundEnded: .constant(false), handler: { (letter: String) in })
        }
    }

}
