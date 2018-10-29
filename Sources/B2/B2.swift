import Vapor
import Service
import Crypto
import Foundation

public class B2Config: Service {
    var keyID: String
    var applicationID: String
    var bucketID: String
    public init(keyID: String, applicationID: String, bucketID: String) {
        self.applicationID = applicationID
        self.keyID = keyID
        self.bucketID = bucketID
    }
}

public final class B2: ServiceType
{
    private let config: B2Config
    
    private init(config: B2Config)
    {
        self.config = config
    }
    
    public static func makeService(for worker: Container) throws -> B2 {
        return B2(config: try worker.make())
    }
    
    public func upload(file: File, req: Request) throws -> Future<Response>
    {
        return try auth(req: req).flatMap { b2Config in
            
            let uploadAuthorizationToken = b2Config.authorizationToken
            let fileName = file.filename
            //let contentType = file.ext
            let sha1 = try SHA1.hash(file.data).hexEncodedString()
            
            var b2Headers: [String: String] = ["Authorization": uploadAuthorizationToken ]
            b2Headers["X-Bz-File-Name"] = fileName
            b2Headers["Content-Type"] = "b2/X-auto"//contentType
            b2Headers["Content-Length"] = "\(file.data.count + 40)"
            b2Headers["X-Bz-Content-Sha1"] = sha1
            
            var headers = HTTPHeaders()
            for (key, value) in b2Headers {
                headers.add(name: key, value: value)
            }
            let request = Request(using: req)
            request.http.method = .POST
            request.http.headers = headers
            request.http.body = file.data.convertToHTTPBody()
            request.http.url = URL(string: b2Config.uploadUrl)!
            
            let client = try req.make(Client.self)
            return client.send(request)
        }
    }
    
    private func auth(req: Request) throws -> Future<b2UploadUrl>
    {
        let keyID = config.keyID
        let applicationID = config.applicationID
        let bucket = config.bucketID
        
        let auth = (keyID + ":" + applicationID).data(using: .utf8)
        
        var header: [String: String]
        header = ["Authorization": "Basic \(auth!.base64EncodedString())"]
        var headers = HTTPHeaders()
        for (key, value) in header {
            headers.add(name: key, value: value)
        }
        
        let request = Request(using: req)
        request.http.method = .GET
        request.http.headers = headers
        request.http.url = URL(string: "https://api.backblazeb2.com/b2api/v2/b2_authorize_account")!
        
        let client = try req.make(Client.self)
        
        return client.send(request)
            .flatMap { try $0.content.decode(b2Auth.self) }
            .flatMap { (b2: b2Auth) -> Future<b2UploadUrl> in
                let headers: [String: String] = ["Authorization": b2.authorizationToken]
                var header = HTTPHeaders()
                for (key, value) in headers {
                    header.add(name: key, value: value)
                }
                
                let request = Request(using: req)
                request.http.method = .POST
                request.http.headers = header
                request.http.body = "{\"bucketId\":\"\(bucket)\"}".data(using: .utf8)!.convertToHTTPBody()
                request.http.url = URL(string: b2.apiUrl + "/b2api/v2/b2_get_upload_url")!
                
                return try req.make(Client.self).send(request)
                    .flatMap { try $0.content.decode(b2UploadUrl.self) }
        }
    }
}



private struct b2Auth: Decodable {
    let absoluteMinimumPartSize: Int
    let accountId: String
    let apiUrl: String
    let authorizationToken: String
    let downloadUrl: String
    let recommendedPartSize: Int
}

private struct b2UploadUrl: Codable {
    let bucketId: String
    let uploadUrl: String
    let authorizationToken: String
}
