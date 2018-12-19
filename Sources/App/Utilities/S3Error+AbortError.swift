import Vapor
import S3

extension S3.Error: AbortError {
    public var status: HTTPResponseStatus {
        switch self {
        case .s3NotRegistered: return .internalServerError
        case .notFound: return .notFound
        case .missingData: return .failedDependency
        case .invalidUrl: return .badRequest
        case .badStringData: return .badRequest
        case let .badResponse(response): return response.http.status
        case let .errorResponse(status, _): return status
        }
    }
    
    public var reason: String {
        switch self {
        case .s3NotRegistered: return "No S3 instance found registered with the current container"
        case .notFound: return "Resource not found at URL"
        case .missingData: return "Unexpectedly got empty response body from S3 API"
        case .invalidUrl: return "Cannot convert string to URL"
        case .badStringData: return "Cannot convert specified string to byte array"
        case let .badResponse(response): return String(data: response.http.body.data ?? Data(), encoding: .utf8) ?? ""
        case let .errorResponse(_, message): return "[" + message.code + "] " + message.message
        }
    }
    
    public var identifier: String {
        switch self {
        case .s3NotRegistered: return "s3NotRegistered"
        case .notFound: return "notFound"
        case .missingData: return "missingData"
        case .invalidUrl: return "invalidUrl"
        case .badStringData: return "badStringData"
        case .badResponse: return "badResponse"
        case .errorResponse: return "errorResponse"
        }
    }
}
