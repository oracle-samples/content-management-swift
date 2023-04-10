# ``Oracle Content Core``

OracleContentCore is the base library upon which other Oracle libraries are built. It contains object defintions and functionality which are common across all Oracle-provided libraries, both public and private. Persons uptaking the Oracle Content libraries will typically interact with **OracleContentCore** as part of the Onboarding process and then interact with a library like **OracleContentDelivery** to retrieve data.

Please see the documentation for other libraries for more detailed information, including Onboarding and Quick Start instructions.

## Topics

### Onboarding 

- ``URLProvider``
- ``LoggingProvider``
- ``SessionProvider``

### Services 
- <doc:ServiceOverview>
- ``BaseService``
- ``BaseServiceTransport``
- ``BaseDownloadService``
- ``BaseDownloadServiceTransport``

### Composition Builder Components
Compositional elements provide functionality for a web service simply by adopting the protocol. 
- ``BaseImplementation``
- ``ImplementsChannelToken``
- ``ImplementsExpand``
- ``ImplementsFields``
- ``ImplementsIsPublishedChannel``
- ``ImplementsLinks``
- ``ImplementsOverrides``
- ``ImplementsSortOrder``
- ``ImplementsTotalResults``
- ``ImplementsVersion``

### Composition Invocation Verbs
- ``ImplementsBaseDownload``
- ``ImplementsCacheProviderDownload``
- ``ImplementsImageProviderDownload``
- ``ImplementsFetchDetail``
- ``ImplementsFetchListing``

### JSON Handling 
JSON handling requires special care to properly decode/encode. This is the due to the manner in which `Date` values are returned in responses. The JSONValue enumeration allows for the parsing of arbitrary JSON not explicitly defined in the data model
- ``LibraryJSONDecoder``
- ``LibraryJSONEncoder``
- ``JSONValue``
- ``DateContainer``

### Query Items 
- ``ConvertToURLQueryItem``
- ``ChannelTokenParameter``
- ``LimitParameter``
- ``OffsetParameter``
- ``PublishedChannelParameter``
- ``QueryParameter``
- ``RenditionFormatParameter``
- ``RenditionTypeParameter``
- ``TaxonomyQueryParameter``
- ``TotalResultsParameter``
