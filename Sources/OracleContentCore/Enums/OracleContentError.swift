// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
// swiftlint:disable line_length

import Foundation

/// High-level errors that may be encountered while performing a library operation
public enum OracleContentError: Error, Equatable {
    
    public enum TriState {
        case yes
        case no
        case maybe
    }
    
    static public func == (lhs: OracleContentError, rhs: OracleContentError) -> Bool {
        switch (lhs, rhs) {
           
        case let (.invalidURL(lval), .invalidURL(rval)):
            return lval == rval
            
        case (.invalidDataReturned, .invalidDataReturned),
             (.noMoreData, .noMoreData),
             (.dataTaskDeallocated, .dataTaskDeallocated),
             (.invalidRequest, .invalidRequest),
             (.dataConversionFailed, .dataConversionFailed),
             (.invalidPostBody, .invalidPostBody),
             (.couldNotCreateService, .couldNotCreateService),
             (.invalidURLSession, .invalidURLSession),
             (.couldNotStoreDownload, .couldNotStoreDownload),
             (.pollingNotCompleted, .pollingNotCompleted),
             (.notModified, .notModified),
             (.noURLReturned, .noURLReturned),
             (.cacheProviderErrorNoURLAvailable, .cacheProviderErrorNoURLAvailable),
             (.imageProviderErrorNoImageAvailable, .imageProviderErrorNoImageAvailable),
             (.missingCacheProvider, .missingCacheProvider),
             (.missingImageProvider, .missingImageProvider):
            
            return true
            
        case  (.imageProviderErrorUnableToStoreImage, .imageProviderErrorUnableToStoreImage):
            
            // consider this as equal even though we can't test the images returned
            return true
        
        case let (.couldNotCreateImageFromURL(lURL), .couldNotCreateImageFromURL(rURL)):
                switch (lURL, rURL) {
                case let (.some(left), .some(right)):
                    return left == right
            
                case (.none, .none):
                    return true
            
                default:
                    return false
                }
            
        case let (.responseStatusError(leftVal, lJSONValue), .responseStatusError(rightVal, rJSONValue)),
             let (.serverErrorBadRequest(leftVal, lJSONValue), .serverErrorBadRequest(rightVal, rJSONValue)),
             let (.serverErrorUnauthorized(leftVal, lJSONValue), .serverErrorUnauthorized(rightVal, rJSONValue)),
             let (.serverErrorForbidden(leftVal, lJSONValue), .serverErrorForbidden(rightVal, rJSONValue)),
             let (.serverErrorConflict(leftVal, lJSONValue), .serverErrorConflict(rightVal, rJSONValue)),
             let (.serverErrorInternalServerError(leftVal, lJSONValue), .serverErrorInternalServerError(rightVal, rJSONValue)),
             let (.serverErrorServiceUnavailable(leftVal, lJSONValue), .serverErrorServiceUnavailable(rightVal, rJSONValue)):
            return leftVal == rightVal && lJSONValue.jsonString() == rJSONValue.jsonString()
            
        case let (.other(lError), .other(rError)),
             let (.pollingJobNotCreated(lError), .pollingJobNotCreated(rError)),
             let (.pollingJobStatusFailed(lError), .pollingJobStatusFailed(rError)):
            // Need to use the NSError bridged form to get to the properties
            let lError = lError as NSError
            let rError = rError as NSError

            return (lError.domain == rError.domain && lError.code == rError.code)
            
        default:
            return false
        }
    }
    
    public typealias RawValue = Int
    
    /// The url could not be constructed
    case invalidURL(String)
    
    /// The version could not be determined
    case invalidVersion
    
    /// The web service returned invalid data and could not be parsed
    case invalidDataReturned
    
    /// No more data exists
    case noMoreData
    
    /// Internal error indicating the data task used to perform the fetch was deallocated before it could return results
    case dataTaskDeallocated
    
    /// Unsuccessful URLResponse error code
    case responseStatusError(Int, JSONValue<NoAsset>)
    
    /// Internal error indicating that the URLRequest could not be created
    case invalidRequest
    
    /// An unexpected error was encountered while trying to cast a generic value to its expected concerete type
    case dataConversionFailed
    
    /// could not format a post body correctly
    case invalidPostBody
    
    /// Unexpected error indicating that the web service could not be created
    case couldNotCreateService
    
    /// The URLSession used is invalid
    case invalidURLSession
    
    /// Download succeeded but could not be copied to the specified location
    case couldNotStoreDownload
    
    /// Polling operation is not yet completed
    case pollingNotCompleted
    
    /// Download succeeded but an image could not be created from the specified URL
    case couldNotCreateImageFromURL(URL?)
    
    /// 400 The request could not be processed because it contains missing or invalid information (such as a validation error on an input field or a missing required value)
    case serverErrorBadRequest(Int, JSONValue<NoAsset>)
    
        /// 401 The request is not authorized. The authentication credentials included with this request are missing or invalid.
    case serverErrorUnauthorized(Int, JSONValue<NoAsset>)
    
    /// 403 Forbidden    The user cannot be authenticated. The user does not have authorization to perform this request.
    case serverErrorForbidden(Int, JSONValue<NoAsset>)
    
    /// 404 Not Found    The request includes a resource URI that does not exist.
    case serverErrorNotFound(Int, JSONValue<NoAsset>)
    
    /// 409 Conflict    The request could not be completed due to a conflict with the current state of the resource. Either the version number does not match, or a duplicate resource was requested.
    case serverErrorConflict(Int, JSONValue<NoAsset>)
    
    /// 500 Internal Server Error    The server encountered an unexpected condition that prevented it from fulfilling the request.
    case serverErrorInternalServerError(Int, JSONValue<NoAsset>)
    
    /// 503 Service Unavailable    The server is unable to handle the request due to temporary overloading or maintenance of the server. The REST web application is not currently running.
    case serverErrorServiceUnavailable(Int, JSONValue<NoAsset>)
    
    /// The initial service failed so a JobID was not created
    case pollingJobNotCreated(Error)
    
    /// The polling function itself failed
    case pollingJobStatusFailed(Error)
    
    /// 304 Response from the server
    case notModified
    
    /// Service was expected to return a URL but not was received
    case noURLReturned
    
    /// Cache provider was unable to provide a URL for the specified key
    case cacheProviderErrorNoURLAvailable
    
    /// Image provider was unable to provide an OracleContentCoreImage for the specified key
    case imageProviderErrorNoImageAvailable
    
    /// Unable to store retrieved image in image provider
    case imageProviderErrorUnableToStoreImage(OracleContentCoreImage)
    
    /// No cache provider was specified
    case missingCacheProvider
    
    /// No image provider was specified
    case missingImageProvider
    
    /// Some other error generated by the system
    case other(Error)
}

extension OracleContentError {
    
    public var rawError: Error {
        switch self {
        case .other(let error),
             .pollingJobStatusFailed(let error),
             .pollingJobNotCreated(let error):
            return error
            
        default:
            return self
        }
    }
    
    public var associatedString: String? {
        switch self {
        case .invalidURL(let s):
            return s
            
        default:
            return nil
        }
    }
    
    public var associatedURL: URL? {
        switch self {
        case .couldNotCreateImageFromURL(let url):
            return url
            
        default:
            return nil 
        }
    }
    
    public var associatedJSONValue: JSONValue<NoAsset>? {
        switch self {
        case .responseStatusError(_, let jsonValue),
             .serverErrorBadRequest(_, let jsonValue),
             .serverErrorUnauthorized(_, let jsonValue),
             .serverErrorForbidden(_, let jsonValue),
             .serverErrorNotFound(_, let jsonValue),
             .serverErrorConflict(_, let jsonValue),
             .serverErrorInternalServerError(_, let jsonValue),
             .serverErrorServiceUnavailable(_, let jsonValue):
            
            return jsonValue
            
        default:
            return nil
        }
    }
    
    public var associatedServerStatusCode: Int? {
        switch self {
        case .responseStatusError(let statusCode, _),
             .serverErrorBadRequest(let statusCode, _),
             .serverErrorUnauthorized(let statusCode, _),
             .serverErrorForbidden(let statusCode, _),
             .serverErrorNotFound(let statusCode, _),
             .serverErrorConflict(let statusCode, _),
             .serverErrorInternalServerError(let statusCode, _),
             .serverErrorServiceUnavailable(let statusCode, _):
            
            return statusCode
            
        default:
            return nil
        }
    }
    
    public var userInfo: [String: Any]? {
        
        switch self {
        case .other(let error):
            return (error as NSError).userInfo
            
        default:
            guard let data = try? LibraryJSONEncoder().encode(self.associatedJSONValue),
                  let e = try? LibraryJSONDecoder().decode(OracleContentErrorUserInfo.self, from: data) else {
                    return nil
                   
            }
            
            return ["errorResponse": e]
        }
    }
}

extension OracleContentError: LocalizedError {
    
    /// String descriptions of each possible error value 
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let serviceSpecificMessage):
            return "Unable to build a valid URL. \(serviceSpecificMessage)"
            
        /// The version could not be determined
        case .invalidVersion:
            return "Could not determine the API version"
            
        /// The web service returned invalid data and could not be parsed
        case .invalidDataReturned:
            return "The data returned by the web service could not be converted into the expected data type"
            
        /// No more data exists
        case .noMoreData:
            return "No more data exists"
            
        /// Internal error indicating the data task used to perform the fetch was deallocated before it could return results
        case .dataTaskDeallocated:
            return "Unexpected internal error. The data task was deallocated before it could return results"
            
        /// Unsuccessful URLResponse error code
        case let .responseStatusError(statusCode, value):
            
            var displayString: String = "Could not retrieve data"
            
            if let simpleString = value.stringValue() {
                displayString = simpleString
            } else if let json = value.objectValue(),
                let detail = json["detail"],
                let detailString = detail.stringValue() {
                displayString = detailString
            }
            return "Error \(statusCode): \(displayString)"
            
        /// Internal error indicating that the URLRequest could not be created
        case .invalidRequest:
            return "Could not build a web service request"
            
        case .dataConversionFailed:
            return "Data conversion failed"
            
        /// could not format a post body correctly
        case .invalidPostBody:
            return "The POST body could not be created"
            
        case .couldNotCreateService:
            return "Could not create web service"
            
        case .invalidURLSession:
            return "The URLSession to use for the web service call is invalid"
            
        case .couldNotStoreDownload:
            return "Download succeeded, but file could not be copied to the specified directory"
            
        case .pollingNotCompleted:
            return "Polling job has not yet completed"
            
        case .couldNotCreateImageFromURL:
            return "Download succeeded, but an image could not be created from the URL returned"
            
        /// 400
        case .serverErrorBadRequest:
            let returnValue = "The request could not be processed because it contains missing or invalid information (such as a validation error on an input field or a missing required value)."
            
            return returnValue
    
        /// 401
        case .serverErrorUnauthorized:
            return "The request is not authorized. The authentication credentials included with this request are missing or invalid."
            
        /// 403
        case .serverErrorForbidden:
            return "The user cannot be authenticated. The user does not have authorization to perform this request."
            
        /// 404
        case .serverErrorNotFound:
            return "The request includes a resource URI that does not exist."
            
        /// 409
        case .serverErrorConflict:
            return "The request could not be completed due to a conflict with the current state of the resource. Either the version number does not match, or a duplicate resource was requested."
            
        /// 500
        case .serverErrorInternalServerError:
            return "The server encountered an unexpected condition that prevented it from fulfilling the request."
            
        /// 503
        case .serverErrorServiceUnavailable:
            return "The server is unable to handle the request due to temporary overloading or maintenance of the server. The REST web application is not currently running."
            
        case .pollingJobStatusFailed(let error):
            return "The job status service failed. Error: \(error.localizedDescription)"
            
        case .pollingJobNotCreated(let error):
            return "The initial service failed. Polling not attempted. Error: \(error.localizedDescription)"
            
        case .notModified:
            return "The item requested was not returned. It has not been modified on the server."
            
        case .noURLReturned:
            return "Service was expected to return a URL but not was received."
            
        case .cacheProviderErrorNoURLAvailable:
            return "Cache provider was unable to provide a URL for the specified key"
            
        case .imageProviderErrorNoImageAvailable:
            return "Image provider was unable to provide an OracleContentCoreImage for the specified key"
            
        case .imageProviderErrorUnableToStoreImage:
            return "Unable to store the retrieved image in the image provider"
            
        case .missingCacheProvider:
            return "Unable to find a cache provider to use for download"
            
        case .missingImageProvider:
            return "Unable to find an image provider to use for download"
            
        case .other(let error):
           return  error.localizedDescription
        }
    }
    
}
