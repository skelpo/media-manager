import Vapor
import Service
import Crypto
import Foundation

private var b2CacheKey = "__b2_authorization_token"

public struct B2Config: Service {
    public let keyID: String
    public let applicationID: String
    public let bucketID: String
    public init(keyID: String, applicationID: String, bucketID: String) {
        self.applicationID = applicationID
        self.keyID = keyID
        self.bucketID = bucketID
    }
}

public final class B2: ServiceType {
    private let config: B2Config
    private let client: Client
    private let cache: KeyedCache
    
    private init(config: B2Config, client: Client, cache: KeyedCache) {
        self.config = config
        self.client = client
        self.cache = cache
    }
    
    public static func makeService(for worker: Container) throws -> B2 {
        return B2(
            config: try worker.make(),
            client: try worker.client(),
            cache: try worker.make()
        )
    }
    
    public func upload(file: File) throws -> Future<Response> {
        return authorize()
            .flatMap(self.getUploadUrl)
            .flatMap { uploadUrl in
                let uploadAuthorizationToken = uploadUrl.authorizationToken
                let fileName = file.filename
                
                let sha1 = try SHA1.hash(file.data).hexEncodedString()
                
                var b2Headers: [String: String] = ["Authorization": uploadAuthorizationToken]
                b2Headers["X-Bz-File-Name"] = fileName
                b2Headers["Content-Type"] = file.contentType?.description ?? "b2/X-auto"
                b2Headers["Content-Length"] = "\(file.data.count + 40)"
                b2Headers["X-Bz-Content-Sha1"] = sha1
                
                let headers = HTTPHeaders(b2Headers.map { $0 })
                
                let request = Request(using: self.client.container)
                request.http.method = .POST
                request.http.headers = headers
                request.http.body = file.data.convertToHTTPBody()
                request.http.url = URL(string: uploadUrl.uploadUrl)!
                
                return self.client.send(request)
        }
    }
    
    private func authorize() -> Future<B2Auth> {
        return cache.get(b2CacheKey, as: B2Auth.self)
            .flatMap { auth in
                if let auth = auth {
                    return self.client.container.future(auth)
                }
                
                let keyID = self.config.keyID
                let applicationID = self.config.applicationID
                let auth = ((keyID + ":" + applicationID).data(using: .utf8) ?? Data()).base64EncodedString()
                
                let request = Request(using: self.client.container)
                request.http.method = .GET
                request.http.headers.add(name: "Authorization", value: "Basic \(auth)")
                request.http.url = URL(string: "https://api.backblazeb2.com/b2api/v2/b2_authorize_account")!
                
                return self.client.send(request)
                    .flatMap { try $0.content.decode(B2Auth.self) }
                    .flatMap { self.cache.set(b2CacheKey, to: $0).transform(to: $0) }
        }
    }
    
    private func getUploadUrl(auth: B2Auth) throws -> Future<B2UploadUrl> {
        let request = Request(using: client.container)
        request.http.method = .POST
        request.http.headers.add(name: "Authorization", value: auth.authorizationToken)
        try request.content.encode(json: B2UploadUrlRequest(bucketId: config.bucketID))
        request.http.url = URL(string: auth.apiUrl + "/b2api/v2/b2_get_upload_url")!
        
        return client.send(request)
            .flatMap { try $0.content.decode(B2UploadUrl.self) }
    }
}

private struct B2Auth: Codable {
    let absoluteMinimumPartSize: Int
    let accountId: String
    let apiUrl: String
    let authorizationToken: String
    let downloadUrl: String
    let recommendedPartSize: Int
}

private struct B2UploadUrl: Codable {
    let bucketId: String
    let uploadUrl: String
    let authorizationToken: String
}

private struct B2UploadUrlRequest: Encodable {
    let bucketId: String
}

public extension Container {
    public func b2() throws -> B2 {
        return try B2.makeService(for: self)
    }
}
