//
//  CurrentSelectionView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/18/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import SwiftUI

struct CurrentSelectionView: View {

    @Binding var text: String
    var handler: () -> Void

    var body: some View {
        Button(action: {
            if (self.text != "") {
                self.handler()
            }
        }) {
            Text(text.count > 0 ? text.uppercased() : " ")
                .fontWeight(.semibold)
                .font(.title)
                .padding()
                .frame(width: UIScreen.main.bounds.width - 60)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(40)
        }
            .padding(.top, 20)
    }

}

struct CurrentSelectionView_Previews: PreviewProvider {

    static var previews: some View {
        CurrentSelectionView(text: .constant("Quest"), handler: {})
    }

}
