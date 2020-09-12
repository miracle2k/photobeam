//
//  BackgroundSimple.swift
//  photobeam
//
//  Created by Michael on 9/9/20.
//

import SwiftUI

struct BackgroundSimple: View {
    let color: Color;
    let rightColor: Color;
//
    init(color: Color, rightColor: Color) {
        self.color = color
        self.rightColor = rightColor
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle().fill(self.color)
            Rectangle().fill(self.rightColor)
                .frame(width: 20)
        }.frame(minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
        ).ignoresSafeArea()
    }
}

struct BackgroundSimple_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundSimple(color: Color(#colorLiteral(red: 0.4000000059604645, green: 0.18039216101169586, blue: 0.6078431606292725, alpha: 1)), rightColor: Color.red)
    }
}
