// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore
import OracleContentDelivery
import SwiftUI
import Combine

struct ImageProviderAssetListing: View {
    @ObservedObject var model = ImageProviderAssetListingModel()
    
    init() {
        InMemoryImageCache.instance.clear()
    }
    
    var body: some View {
        ZStack {
            VStack {
                if self.model.assets.isEmpty {
                    NoAssetsAvailableView
                } else {
                    ListingView
                }
            }
            .popover(isPresented: self.$model.showError) {
                Text(self.model.error?.localizedDescription ?? "Unknown error")
            }
            .task {
                if self.model.assets.isEmpty {
                    await self.model.fetchAssetListingIfNeeded(nil)
                }
            }
            .presentationDetents([.height(100)])
            
            if self.model.isLoadingPage {
                FetchInProgressView()
            }
        }
        .navigationTitle("Image Provider")
        
    }
    
    @ViewBuilder
    var NoAssetsAvailableView: some View {
        if !self.model.isLoadingPage {
            Text("No assets available")
        }
    }
    
    @ViewBuilder
    var ListingView: some View {
        ScrollViewReader { sr in
            List {
                ForEach(self.model.assets, id: \.self) { asset in
                    
                    NavigationLink {
                      
                        LazyView(
                            ImageProviderAssetView(asset)
                        )
     
                    } label: {
                        Text(asset.name)
                            .onAppear {
                                Task {
                                    await self.model.fetchAssetListingIfNeeded(asset)
                                }
                            }
                    }

                }
            }
        }
    }
    
}

@MainActor
class ImageProviderAssetListingModel: ObservableObject {
    
    @Published var assets = [Asset]()
    @Published var error: Error?
    @Published var showError = false
    
    @Published var isLoadingPage = false
    private var canLoadMorePages = true
    
    private var service: ListAssets<Assets>!
    
    
    func fetchAssetListingIfNeeded(_ asset: Asset?) async {
        
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        if asset == nil {
            await self.fetch()
        } else {
            guard let asset = asset else {
                return
            }
            
            // infinite scroll capability
            var threshhold = self.assets.index(self.assets.endIndex, offsetBy: -5)
            if threshhold < 0 {
                threshhold = 0
            }
            
            if self.assets.firstIndex(where: { $0.identifier == asset.identifier }) == threshhold || asset == self.assets.last {
                await self.fetch()
            }
        }
        
        self.isLoadingPage = false
        
    }
    
    func fetch() async {
        
        // Utilizing a QueryBuilder for illustration purposes
        // While you could certainly form a query like:  ".query(rawText: "type eq \"Image\" AND fileExtension eq \"jpg\"")"
        // You may find it more useful to use a QueryBuilder for complex queries
        // See the QueryBuilder unit tests in OracleContentCore for more examples
        
        let typeNode = QueryNode.equal(field: "type", value: "Image")
        let fileExtensionNode = QueryNode.equal(field: "fileExtension", value: "jpg")
        let query = QueryBuilder(node: typeNode).and(fileExtensionNode)
        
        if service == nil {
            service = DeliveryAPI
                        .listAssets()
                        .limit(50)
                        .query(query)
        }
        
        do {
            self.isLoadingPage = true
            
            let result: Assets = try await service.fetchNextAsync()
            self.assets.append(contentsOf: result.items)
        } catch (let error) {
            self.error = error
            self.showError = true
            self.canLoadMorePages = false
        }
    }
}

struct ImageProviderAssetListing_Previews: PreviewProvider {
    static var previews: some View {
        CacheProviderAssetListing()
    }
}






