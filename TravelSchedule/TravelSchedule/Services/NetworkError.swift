import Foundation

enum NetworkErrorType {
    case noInternet
    case serverError
    case timeout
    case other
    
    var imageName: String {
        switch self {
        case .noInternet:
            return "errorsNoInternet"
        case .serverError, .timeout, .other:
            return "errorsServerError"
        }
    }
    
    var titleKey: String {
        switch self {
        case .noInternet:
            return "error_no_internet"
        case .serverError:
            return "error_server_error"
        case .timeout:
            return "error_server_error"
        case .other:
            return "error_title"
        }
    }
}

func determineErrorType(_ error: Error) -> NetworkErrorType {
    let nsError = error as NSError
    
    // OpenAPI ClientError
    if nsError.domain == "OpenAPIRuntime.ClientError" || String(describing: type(of: error)).contains("ClientError") {
        let errorDescription = error.localizedDescription.lowercased()
        if errorDescription.contains("соединение") && errorDescription.contains("интернет") {
            return .noInternet
        }
        
        if errorDescription.contains("connection") && errorDescription.contains("internet") {
            return .noInternet
        }
        
        if errorDescription.contains("not connected") {
            return .noInternet
        }
        
        if errorDescription.contains("network") && (errorDescription.contains("lost") || errorDescription.contains("unavailable")) {
            return .noInternet
        }
        
        if errorDescription.contains("timed out") || errorDescription.contains("time out") {
            return .timeout
        }
        
        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
            if underlyingError.domain == NSURLErrorDomain {
                return determineErrorType(underlyingError)
            }
        }
        return .serverError
    }
    
    if nsError.domain == NSURLErrorDomain {
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet,  // -1009
            NSURLErrorNetworkConnectionLost,    // -1005
            NSURLErrorDataNotAllowed:           // -1020
            return .noInternet
            
        case NSURLErrorTimedOut:  // -1001
            return .timeout
            
        case NSURLErrorBadServerResponse,  // -1011
            NSURLErrorCannotFindHost,     // -1003
            NSURLErrorCannotConnectToHost, // -1004
            NSURLErrorDNSLookupFailed:     // -1006
            return .serverError
            
        default:
            return .other
        }
    }
    
    if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
        return determineErrorType(underlyingError)
    }
    return .serverError
}
