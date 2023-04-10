// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import OracleContentCore
import OracleContentDelivery
import Combine

/// Detail view for a single Image asset
/// Utilizes `Future`-based invocation verbs when making web service calls
/// Downloads images using the `downloadImage` invocation verb, which returns a UIImage (on iOS) in its result property
struct ImageProviderAssetView: View {
    @ObservedObject var model: ImageProviderAssetModel
    
    init(_ asset: Asset) {
        self.model = ImageProviderAssetModel(asset)
    }
    
    var body: some View {
        VStack {
            Group {
                if self.model.thumbnail == nil {
                    Color.gray.opacity(0.2)
                } else {
                    Image(uiImage: self.model.thumbnail!).resizable().scaledToFit()
                }
            }
            
            List {
                Section(header: Text("Name")) {
                    Text(self.model.asset.name)
                }
                
                Section(header: Text("Identifier")) {
                    Text(self.model.asset.identifier)
                }
                
                if self.model.asset.digitalAssetFields != nil {
                    
                    Section(header: Text("Metadata Dimensions")) {
                        Text("\(self.model.asset.digitalAssetFields!.metadata.height) x \(self.model.asset.digitalAssetFields!.metadata.width)")
                    }
                    
                    Section(header: Text("Available Renditions")) {
                        ForEach(self.model.asset.digitalAssetFields!.renditions, id: \.self) { rendition in
                            Text(rendition.name)
                        }
                    }
                   
                }
            }.listStyle(.grouped)
            
        }
        .navigationTitle("Asset Details")
        .task {
            await self.model.fetch()
        }
    }
}

@MainActor
class ImageProviderAssetModel: ObservableObject {
    
    @Published var asset: Asset
    @Published var thumbnail: UIImage?
    @Published var error: Error?
    @Published var showDetailError = false
    @Published var showThumbnailError = false
    @Published var isLoading = false
    
    private var cancellables = [AnyCancellable]()
    
    init(_ asset: Asset) {
        self.asset = asset
    }
    
    func fetch() async {
        await self.fetchDetail()
        await self.fetchThumbnail()
    }
    
    /// Utilize a CacheProvider implementation
    /// Note the form of the initializer used
    func fetchThumbnail() async {
        do {
            let downloadResult = try await DeliveryAPI
                .downloadThumbnail(identifier: self.asset.identifier,
                                   fileGroup: self.asset.fileGroup,
                                   imageProvider: InMemoryImageProvider(),
                                   cacheKey: self.asset.identifier)
                .downloadImageAsync(progress: nil)
            
        
            self.thumbnail = downloadResult.result
            
        } catch (let error) {
            self.showThumbnailError = true
            print(error)
        }
    }
    
    func fetchDetail() async {
        
        self.isLoading = true
        
        do {
            let result = try await DeliveryAPI.readAsset(assetId: self.asset.identifier)
                .expand(.all)
                .fetchAsync()
            
            self.asset = result
            
        } catch (let error) {
            self.error = error
            self.showDetailError = true
        }
        
        self.isLoading = false
    }
}


