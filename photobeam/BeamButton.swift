//
//  BeamButton.swift
//  photobeam
//
//  Created by Michael on 9/8/20.
//

import SwiftUI

struct FilledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(Color(#colorLiteral(red: 1, green: 0.94, blue: 0.99, alpha: 1))).multilineTextAlignment(.center)
            .font(.custom("Roboto Bold", size: 28))
            .padding()
            .background(Color(#colorLiteral(red: 1, green: 0.2862745225429535, blue: 0.6196078658103943, alpha: 1)))
            .cornerRadius(35.5)
            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:4, x:0, y:4)
    }
}


struct GradientBackgroundStyle: ButtonStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [Color("DarkGreen"), Color("LightGreen")]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .padding(.horizontal, 20)
    }
}

