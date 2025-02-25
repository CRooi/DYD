//
//  WelcomeView.swift
//  DYD
//
//  Created by CRooi on 2024/9/23.
//

import ColorfulX
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Image(.avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                Text("Welcome to DYD")
                    .font(.system(.headline, design: .rounded))
                inst
                    .font(.system(.footnote, design: .rounded))
                    .padding(.horizontal, 32)
                Spacer().frame(height: 0)
            }

            VStack(spacing: 16) {
                Spacer()
//                Text(appVersion)
                Text("Interface is unstable, retry if needed.")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ColorfulView(color: .constant(ColorfulPreset.winter.colors))
                .opacity(0.25)
                .ignoresSafeArea()
        )
    }

    var inst: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "1.circle.fill")
                Text("Paste your share link or text.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Image(systemName: "2.circle.fill")
                Text("Parse the video.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "3.circle.fill")
                Text("Download and save the video or music.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
