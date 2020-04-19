//
//  InvalidWordView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/18/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import SwiftUI

struct InvalidWordView: View {

    @Binding var word: String
    @Binding var duplicate: String

    var body: some View {
        Text(
            duplicate.count > 0
                ? "\"\(duplicate.uppercased())\" Has Already Been Found!"
                : word.count > 0
                ? "\"\(word.uppercased())\" Is Not A Valid Word!"
                    : " "
        )
            .foregroundColor(.red)
            .padding()
    }

}

struct InvalidWordView_Previews: PreviewProvider {

    static var previews: some View {
        InvalidWordView(word: .constant("ABCD"), duplicate: .constant(""))
    }

}
