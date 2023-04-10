// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

/**
Allows a conforming service to specify the channel token as part of its web service call.
*/
public protocol ImplementsChannelToken: BaseImplementation {
    
    /**
     Specify the channel token to be added to the web service call
     - parameter channelToken: String
     */
    func channelToken(_ token: String) -> ServiceReturnType
}

public extension ImplementsChannelToken {
    
    func channelToken(_ token: String) -> ServiceReturnType {
        let tokenValue = ChannelTokenParameter.value(token)
        self.addParameter(key: ChannelTokenParameter.keyValue, value: tokenValue)
        return self
    }
}
