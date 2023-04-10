// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore
import OracleContentDelivery
import SwiftUI
import Combine

/// Asset listing view
/// Utilizes `Future` invocation verbs in its model object
struct SimpleAssetListing: View {
    @ObservedObject var model = SimpleAssetListingModel()
    
    var body: some View {
        ZStack {
            VStack {
                if self.model.assets.isEmpty {
                    NoAssetsAvailableView
                } else {
                    ListingView
                }
                
            }
            
            if self.model.isLoadingPage {
                FetchInProgressView()
            }
        }
        .onAppear {
            if self.model.assets.isEmpty {
                self.model.fetchAssetListingIfNeeded(nil)
            }
        }
        .popover(isPresented: self.$model.showError) {
            Text(self.model.error?.localizedDescription ?? "Unknown error")
        }
        .presentationDetents([.height(100)])
        .navigationTitle("Future")
    }
    
    @ViewBuilder
    var NoAssetsAvailableView: some View {
        if !self.model.isLoadingPage {
            Text("No assets available")
        }
    }
    
    @ViewBuilder
    var ListingView: some View {
        List {
            ForEach(self.model.assets, id: \.self) { asset in
                NavigationLink {
                  
                    LazyView(
                        AssetView(asset)
                    )
 
                } label: {
                    Text(asset.name)
                        .onAppear {
                            self.model.fetchAssetListingIfNeeded(asset)
                        }
                        
                }
            }
        }
    }
}

/// Model for the SimpleAssetListing view
/// Utilizes `Future`-based invocation verbs
class SimpleAssetListingModel: ObservableObject {
    
    @Published var assets = [Asset]()
    @Published var error: Error?
    @Published var showError = false
    @Published var isLoadingPage = false
    
    private var canLoadMorePages = true
    private var cancellables = [AnyCancellable]()
    private var service: ListAssets<Assets>?
    
    func fetchAssetListingIfNeeded(_ asset: Asset?) {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        if asset == nil {
            self.fetch()
        } else {
            guard let asset = asset else {
                return
            }
            
            // infinite scroll capability
            var threshhold = self.assets.index(self.assets.endIndex, offsetBy: -10)
            if threshhold < 0 {
                threshhold = 0
            }
            
            if self.assets.firstIndex(where: { $0.identifier == asset.identifier }) == threshhold || asset == self.assets.last {
                self.fetch()
            }

        }
        
    }
    
    func fetch() {
    
        var c: AnyCancellable?
        
        if service == nil {
            service = DeliveryAPI
                        .listAssets()
                        .fields(.all)
                        .query(rawText: "type eq \"Image\" AND fileExtension eq \"jpg\"")
            
        }
        
        self.isLoadingPage = true
        
        c = service?
            .fetchNext()
            .receive(on: RunLoop.main, options: nil)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                    self.showError = true
                    self.canLoadMorePages = false
                    
                default:
                    break
                }
                
                self.cancellables.removeAll { $0 === c }
                self.isLoadingPage = false
                
            }, receiveValue: { assets in
                self.assets.append(contentsOf: assets.items)
            })
        
        c?.store(in: &self.cancellables)
    }
}

struct SimpleAssetListing_Previews: PreviewProvider {
    static var previews: some View {
        SimpleAssetListing()
    }
}


