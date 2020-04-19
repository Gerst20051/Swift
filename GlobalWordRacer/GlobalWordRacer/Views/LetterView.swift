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
    var handler: (String) -> Void

    var body: some View {
        Button(action: {
            self.handler(self.text)
        }) {
            Text(text)
                .fontWeight(.semibold)
                .font(.title)
                .frame(width: 40)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(40)
        }
    }

}

struct LetterView_Previews: PreviewProvider {

    static var previews: some View {
        VStack(spacing: 20) {
            LetterView(text: .constant("A"), handler: { (letter: String) in })
            LetterView(text: .constant("Qu"), handler: { (letter: String) in })
            LetterView(text: .constant("Z"), handler: { (letter: String) in })
        }
    }

}
