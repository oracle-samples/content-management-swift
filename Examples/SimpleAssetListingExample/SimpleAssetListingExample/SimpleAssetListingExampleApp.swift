// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import SwiftUI
import OracleContentCore

/// Main entry point of the sample
/// OnBoarding process is handled in the .onAppear modifier
@main
struct SimpleAssetListingExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    DevURLProtocol.updateCaasSessions()
                
                    Onboarding.urlProvider = MyURLProvider()
                }
        }
    }
}

/// URLProvider implementation
/// Defines the server URL and channel token necessary for service calls to be made
/// Change the URL property to return a URL value pointing to your OCM server
/// Change the deliveryChannelToken property to point to your publishing channel that contains published images
public class MyURLProvider: URLProvider {
    public var url: () -> URL? = {
        
        return URL(string: "https://localhost:3131")!
    }
    
    public var headers: () -> [String : String] = {
        [:]
    }
    
    public var deliveryChannelToken: () -> String? = {
        "e0b6421e73454818948de7b1eaddb091"
    }
}
