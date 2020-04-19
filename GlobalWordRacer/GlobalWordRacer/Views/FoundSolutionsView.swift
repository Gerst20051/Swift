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
            Text(
                list.count > 0
                    ? "\(list.count) Word\(list.count > 1 ? "s": "") Found (\(list.map(self.pointsForWord).reduce(0, +)) Points)"
                    : "No Words Found"
            )
                .foregroundColor(.black)
                .fontWeight(.semibold)
                .font(.headline)

            ScrollView(.vertical) {
                VStack {
                    ForEach(list.reversed(), id: \.self) { word in
                        HStack {
                            Text(word)
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(self.pointsForWord(word))")
                                .foregroundColor(.black)
                        }
                    }
                }.frame(width: UIScreen.main.bounds.width - 60)
            }

            Spacer()
        }
            .frame(width: UIScreen.main.bounds.width - 60, height: 160)
    }

    func pointsForWord(_ word: String) -> Int {
        let wordPointsDistribution = [0, 0, 0, 10, 20, 40, 80, 120, 140, 220, 300]
        return word.count > 11 ? 400 : wordPointsDistribution[word.count]
    }

}

struct FoundSolutionsView_Previews: PreviewProvider {

    static var previews: some View {
        FoundSolutionsView(list: .constant(["Word1", "Word2"]))
    }

}
