//
//  FoundSolutionsView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/18/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import SwiftUI

struct FoundSolutionsView: View {

    @Binding var list: [String]

    var body: some View {
        VStack {
            Text(list.count > 0 ? "\(list.count) Word\(list.count > 1 ? "s": "") Found (\(list.count * 20) Points)" : "No Words Found")
                .fontWeight(.semibold)
                .font(.headline)
                .padding(.top)

            ScrollView(.vertical) {
                VStack {
                    ForEach(list.reversed(), id: \.self) { word in
                        HStack {
                            Text(word)
                            Spacer()
                            Text("\(self.pointsForWord(word))")
                        }
                    }
                }.frame(width: UIScreen.main.bounds.width - 60)
            }

            Spacer()
        }.frame(width: UIScreen.main.bounds.width - 60, height: 160)
    }

    func pointsForWord(_ word: String) -> Int {
        return 20
    }

}

struct FoundSolutionsView_Previews: PreviewProvider {

    static var previews: some View {
        FoundSolutionsView(list: .constant(["Word1", "Word2"]))
    }

}
