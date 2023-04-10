// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import SwiftUI

/// Top-level UI allowing navigation into the different example types
public struct MainView: View {
    
    init() {
        
        // For simplicity - always clear the GalleryFileCache when launching the application
        GalleryFileCache.instance.clear()
        
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                NavigationLink("Fetch with Future", destination: LazyView(SimpleAssetListing()))
                
                NavigationLink("Fetch Async", destination: LazyView(AsyncAwaitSimpleAssetListing()))
                
                NavigationLink("Cache Provider", destination: LazyView(CacheProviderAssetListing()))
                
                NavigationLink("Image Provider", destination: LazyView(ImageProviderAssetListing()))
                
                Button {
                    GalleryFileCache.instance.clear()
                    InMemoryImageCache.instance.clear()
                    
                } label: {
                    Text("Clear Caches")
                }
                
                
                
            }
            .navigationTitle("Simple Asset Listing")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
