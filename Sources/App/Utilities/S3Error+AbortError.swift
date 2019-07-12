import Vapor
import S3

extension S3.Error: AbortError {
    public var description: String { self.reason }

    public var status: HTTPResponseStatus {
        switch self {
        case .s3NotRegistered: return .internalServerError
        case .notFound: return .notFound
        case .missingData: return .failedDependency
        case .invalidUrl: return .badRequest
        case .badStringData: return .badRequest
        case let .badResponse(response): return response.status
        case let .errorResponse(status, _): return status
        case let .badClientResponse(response): return HTTPResponseStatus(statusCode: Int(response.status.code))
        }
    }
    
    public var reason: String {
        switch self {
        case .s3NotRegistered: return "No S3 instance found registered with the current container"
        case .notFound: return "Resource not found at URL"
        case .missingData: return "Unexpectedly got empty response body from S3 API"
        case .invalidUrl: return "Cannot convert string to URL"
        case .badStringData: return "Cannot convert specified string to byte array"
        case let .badResponse(response): return String(data: response.body.data ?? Data(), encoding: .utf8) ?? ""
        case let .errorResponse(_, message): return "[" + message.code + "] " + message.message
        case let .badClientResponse(response):
            let data = response.body.map { Data($0.readableBytesView) } ?? Data()
            return String(data: data, encoding: .utf8) ?? ""
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
        case .badClientResponse: return "badAPIResponse"
        }
    }
}
