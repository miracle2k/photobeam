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
            .opacity(configuration.isPressed ? 0.7 : 1)
            .foregroundColor(Color(#colorLiteral(red: 1, green: 0.94, blue: 0.99, alpha: 1))).multilineTextAlignment(.center)
            .font(.system(size: 24, weight: .bold))
            .padding(20)
            .background(Color(#colorLiteral(red: 1, green: 0.2862745225429535, blue: 0.6196078658103943, alpha: 1)))
            .cornerRadius(35.5)
            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:4, x:0, y:4)
    }
}

struct LightStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(#colorLiteral(red: 1, green: 0.94, blue: 0.99, alpha: 1)))
    }
}

extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}


struct FilledField: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(20)
            .background(Color(#colorLiteral(red: 0.9764705896377563, green: 0.7843137383460999, blue: 0.054901961237192154, alpha: 1)))
            .cornerRadius(35.5)
            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:4, x:0, y:4)
    }
}

struct ButtonLikeRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20)
            .background(Color(#colorLiteral(red: 0.9764705896377563, green: 0.7843137383460999, blue: 0.054901961237192154, alpha: 1)))
            .cornerRadius(35.5)
            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:4, x:0, y:4)
    }
}


struct TextFieldWithButton: ViewModifier {
    let action: () -> Void;
    
    func body(content: Content) -> some View {
        HStack {
            content
            Button(action: self.action) { Text("test") }
        }.modifier(ButtonLikeRectangle())
    }
}
