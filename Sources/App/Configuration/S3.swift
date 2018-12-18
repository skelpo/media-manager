import S3Storage
import Vapor
import S3

func s3(_ services: inout Services, cache: StorageControllerCache)throws {
    guard
        let bucket: String = Environment.get("S3_BUCKET"),
        let accessKey: String = Environment.get("S3_ACCESS_KEY"),
        let secretKey: String = Environment.get("S3_SECRET_KEY"),
        let rawRegion: String = Environment.get("S3_REGION"),
        let region = Region.init(rawValue: rawRegion)
    else {
        throw Abort(.internalServerError, reason: "Missing S3 environment variable(s)")
    }
    
    let config = S3Signer.Config(accessKey: accessKey, secretKey: secretKey, region: region, securityToken: Environment.get("S3_SECURITY_TOKEN"))
    let signer = try S3Signer(config)
    
    try services.register(S3(defaultBucket: bucket, signer: signer))
    cache.register(storage: S3Storage.self, slug: "s3")
}
