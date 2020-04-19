//
//  TitleView.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/18/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import SwiftUI

struct TitleView: View {

    var title: String

    var body: some View {
        Text(title)
            .fontWeight(.semibold)
            .font(.system(size: 40))
            .frame(width: UIScreen.main.bounds.width, height: 100)
            .padding(10)
            .background(Color.blue)
            .foregroundColor(.white)
    }

}

struct TitleView_Previews: PreviewProvider {

    static var previews: some View {
        TitleView(title: "Global Word Racer")
    }

}
