// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Internal-only helpers allowing web service "results" to be transformed into true `Swift.Result` objects.
public enum ResultFromResponse {
    
    /// Use DeliveryAPI.data(from:response:) or ManagementAPI.data(from:response:) instead
    public static func data(from data: Data?, response: HTTPURLResponse?) throws -> Data {
        
        // Validate the HTTPURLResponse if it exists
        // If it does not exist, the error will be picked up while investigating the data parameter
        if let response = response,
           let foundError = ResultFromResponse.error(from: data, statusCode: response.statusCode) {
                throw foundError
        }

        // Reject if no data is returned
        guard let data = data else {
            throw OracleContentError.invalidDataReturned
        }
        
        return data
    }
    
}

extension ResultFromResponse {
    /// Transform a URLResponse into a Result<DownloadResult<URL>, Error>
    /// - parameter URL: The download URL to be returned in a success case
    /// - parameter response: The URLResponse received by the web service
    /// - parameter error: The Error received by the web service
    /// - returns Result<URL, Error>
    internal static func result
    (
        fileURL: URL?,
        response: URLResponse?,
        error: Error?
    ) -> Result<DownloadResult<URL>, Error> {
        
        // Reject if an error exists
        if let error = error {
            Onboarding.logError("Error returned from web service call: \(error)")
            return .failure(error)
        }
        
        // Validate the HTTPURLResponse if it exists
        // If it does not exist, the error will be picked up while investigating the data parameter
        
        var headers: [AnyHashable: Any] = [:]
        if let response = response as? HTTPURLResponse {
            if let foundError = ResultFromResponse.error(from: fileURL, statusCode: response.statusCode) {
                return .failure(foundError)
            }
            
            headers = response.allHeaderFields
        }
        
        // Reject if no data is returned
        guard let downloadURL = fileURL else {
            return .failure(OracleContentError.noURLReturned)
        }
        
        return .success(DownloadResult(result: downloadURL, headers: headers ))
    }
    
    /// Transform a URLResponse into the Result<(Data?, URLResponse?), Error>
    /// Used by "no parsing" services to return raw data
    /// - parameter data: The Data returned by the web service
    /// - parameter response: The URLResponse returned by the web service
    /// - parameter error: The Error returned by the web service.
    /// - returns Result<(Data?, URLResponse?), Error>
    ///
    internal static func result
    (
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Result<(Data?, URLResponse?), Error> {
        
        // Reject if an error exists
        if let error = error {
            Onboarding.logError("error calling service: \(error)")
            return Result.failure(error)
        }
        
        // Validate the HTTPURLResponse if it exists
        // If it does not exist, the error will be picked up while investigating the data parameter
        if let response = response as? HTTPURLResponse,
           let foundError = ResultFromResponse.error(from: data, statusCode: response.statusCode) {
                return Result.failure(foundError)
        }
        
        return Result.success((data, response))
    }
    
}

extension ResultFromResponse {
    /// Called when creating an OracleContentError.responseStatusError
    /// That error will have data encoded into a JSONValue<NoAsset> since it can represent any type of dictionary
    private static func parse(_ data: Data?) -> JSONValue<NoAsset> {
        
        guard let data = data else {
            return JSONValue.null
        }
        
        if let jsonData = try? LibraryJSONDecoder().decode(JSONValue<NoAsset>.self, from: data) {
            return jsonData
        } else if let stringFromData = String(data: data, encoding: .utf8) {
            return JSONValue(stringLiteral: stringFromData)
        } else {
            return JSONValue.null
        }
    }
    
    private static func parse(fileURL: URL?) -> JSONValue<NoAsset> {
    
        guard let foundURL = fileURL,
              let data = try? Data(contentsOf: foundURL) else {
                
            return JSONValue.null
        }
        return ResultFromResponse.parse(data)
    }
    
    private static func error(from data: Data?, statusCode: Int) -> OracleContentError? {
        let acceptableCodes = 200...299
        if !acceptableCodes.contains(statusCode) {
            
            let errorResponse = ResultFromResponse.parse(data)
            let error = ResultFromResponse.error(from: statusCode, errorResponse: errorResponse)
            return error
        }
        
        /// Fail if no data is returned
        if data == nil {
            return .invalidDataReturned
        }
        
        return nil
    }
    
    private static func error(from url: URL?, statusCode: Int) -> OracleContentError? {
        
        let acceptableCodes = 200...299
        if !acceptableCodes.contains(statusCode) {
            let errorResponse = ResultFromResponse.parse(fileURL: url)
            let error = ResultFromResponse.error(from: statusCode, errorResponse: errorResponse)
            return error
        }
        
        return nil
    }
    
    private static func error(from statusCode: Int, errorResponse: JSONValue<NoAsset>) -> OracleContentError? {
        switch statusCode {
            
        case 304:
            return .notModified
            
        case 400:
            return .serverErrorBadRequest(statusCode, errorResponse)
            
        case 401:
            return .serverErrorUnauthorized(statusCode, errorResponse)
            
        case 403:
            return .serverErrorForbidden(statusCode, errorResponse)
            
        case 404:
            return .serverErrorNotFound(statusCode, errorResponse)
            
        case 409:
            return .serverErrorConflict(statusCode, errorResponse)
            
        case 500:
            return .serverErrorInternalServerError(statusCode, errorResponse)
            
        case 503:
            return .serverErrorServiceUnavailable(statusCode, errorResponse)
            
        default:
            return .responseStatusError(statusCode, errorResponse)
        }
    }
}
