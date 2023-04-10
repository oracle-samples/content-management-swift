// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

///
/// Interfaces for the Delivery SDK relating to Taxonomies
///
extension DeliveryAPI {
    /**
    Retrieve a listing of published taxonomies
     
    The data model object is of type ``Taxonomies``
     
    Service is executable using the `fetchNext` invocation verb defined via conformance to `ImplementsFetchListing`
    - returns: ``ListTaxonomies``  service
    
    Swift Usage Example:
     ```swift
    let service = DeliveryAPI.listTaxonomies().channelToken("12345")
    
    service.fetchNext { result in
    // handler code
    }
    ```
    */
    public class func listTaxonomies() -> ListTaxonomies<Taxonomies> {
        return ListTaxonomies()
    }
    
    /**
    Retrieve information about the specified taxonomy
     
    The data model object is of type ``Taxonomy``
     
    Service is executable using the `fetch` invocation verb defined via conformance to `ImplementsFetchDetail`
     
    - returns: ``ReadTaxonomy`` service
    
    Swift Usage Example:
     ```swift
    let service = DeliveryAPI.readTaxonomy(taxonomyId: "123").channelToken("12345")
    
    service.fetch { result in
    // handler code
    }
    ```
    */
    public class func readTaxonomy(taxonomyId: String) -> ReadTaxonomy<Taxonomy> {
        return ReadTaxonomy(taxonomyId: taxonomyId)
    }
    
    /**
     Retrieve a listing of published categories
     
     The data model object is of type ``TaxonomyCategories``
     
     Service is executable using the `fetchNext` invocation verb defined via conformance to `ImplementsFetchListing`
     
     - parameter taxonomyId: The identifier of the taxonomy for which you wish to fetch categories
     - returns: ``ListTaxonomyCategories`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI.listTaxonomyCategories(taxonomyId: "123").channelToken("12345")
     
     service.fetchNext { result in
     // handler code
     }
     ```
     */
    public class func listTaxonomyCategories(taxonomyId: String) -> ListTaxonomyCategories<TaxonomyCategories> {
        return ListTaxonomyCategories(taxonomyId: taxonomyId)
    }
    
    /**
     Returns a published category
      
     The data model object is of type ``TaxonomyCategory``
     
     Service is executable using the `fetch` invocation verb defined via conformance to `ImplementsFetchDetail`
     
     - parameter taxonomyId: The identifier of the taxonomy
     - parameter categoryId: The identifier of the category
     - returns: ``ReadTaxonomyCategory`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
                    .readTaxonomyCategory(taxonomyId: "123", categoryId: "456")
                    .channelToken("12345")
     
     service.fetch { result in
     // handler code
     }
     ```
     */
    public class func readTaxonomyCategory(taxonomyId: String, categoryId: String) -> ReadTaxonomyCategory<TaxonomyCategory> {
        return ReadTaxonomyCategory(taxonomyId: taxonomyId, categoryId: categoryId)
    }
}
