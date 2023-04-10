// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

/// Simple view which contains a progress indicator
struct FetchInProgressView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 150, height: 150)
                .foregroundColor(.gray.opacity(0.3))
            
            ProgressView()
                .tint(.red)
                .scaleEffect(x: 4, y: 4, anchor: .center)
        }

    }
}
