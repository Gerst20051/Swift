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

    var body: some View {
        Button(action: {
            print(self.text)
        }) {
            Text(text)
                .fontWeight(.semibold)
                .font(.title)
                .frame(width: 40)
                .padding()
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .foregroundColor(.white)
                .cornerRadius(40)
        }
    }

}

struct LetterView_Previews: PreviewProvider {

    static var previews: some View {
        VStack(spacing: 20) {
            LetterView(text: .constant("A"))
            LetterView(text: .constant("Qu"))
            LetterView(text: .constant("Z"))
        }
    }

}
