// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public protocol ImplementsIsPublishedChannel: BaseImplementation {
    /**
     Determines how to treat channels mentioned in a query.
     
     - parameter isPublishedChannel: Bool. If `true`, then the channels mentioned in query parameter will be considered as published channels else they will be considered as targeted channels.
     */
     func isPublishedChannel(_ isPublishedChannel: Bool) -> Self

}

extension ImplementsIsPublishedChannel {

    public func isPublishedChannel(_ isPublishedChannel: Bool) -> Self {
        let publishedChannelParameter = PublishedChannelParameter.value(isPublishedChannel)
        self.addParameter(key: PublishedChannelParameter.keyValue, value: publishedChannelParameter)
        return self
    }
}

