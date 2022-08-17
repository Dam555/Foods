//
//  LoadingProgressView.swift
//  
//
//  Created by Damjan on 16.08.2022.
//

import SwiftUI

public struct LoadingProgressView: View {

    private let layout = Layout()

    public init() { }

    public var body: some View {
        VStack(spacing: layout.verticalSpacing) {
            ProgressView()
            Text(Localized.loading)
                .font(layout.loadingFont)
                .foregroundColor(.gray)
        }
    }
}

private extension LoadingProgressView {

    struct Layout {
        let verticalSpacing: CGFloat = 10
        let loadingFont = Font.system(size: 13)
    }
}

struct LoadingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        return LoadingProgressView()
    }
}
