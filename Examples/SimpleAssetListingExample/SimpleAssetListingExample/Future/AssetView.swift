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
struct AssetView: View {
    @ObservedObject var model: AssetModel
    
    init(_ asset: Asset) {
        self.model = AssetModel(asset)
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
        .onAppear {
            self.model.fetch()
        }
    }
}

class AssetModel: ObservableObject {
    
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
    
    func fetch() {
        self.fetchDetail()
        self.fetchThumbnail()
    }
    
    func fetchThumbnail() {
        var c: AnyCancellable?
        
        c = DeliveryAPI
            .downloadThumbnail(identifier: self.asset.identifier, fileGroup: self.asset.fileGroup)
            .download(progress: nil)
            .map {
                UIImage(contentsOfFile: $0.result.path)
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(_):
                    self.showThumbnailError = true
                    
                default:
                    break
                }
                
                self.cancellables.removeAll { $0 === c }
            }, receiveValue: { image in
                self.thumbnail = image
            })
        
        c?.store(in: &self.cancellables)
    }
    
    func fetchDetail() {
        
        self.isLoading = true
        
        var c: AnyCancellable?
        
        c = DeliveryAPI
            .readAsset(assetId: self.asset.identifier)
            .expand(.all)
            .fetch()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                    self.showDetailError = true
                    
                default:
                    break
                }
                
                self.cancellables.removeAll { $0 === c }
                self.isLoading = false
                
            }, receiveValue: { asset in
                self.asset = asset
            })
            
        c?.store(in: &self.cancellables)
        
       
    }
}
