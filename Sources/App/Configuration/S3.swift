import S3Storage
import Vapor
import S3

func s3(_ services: inout Services, cache: StorageControllerCache)throws {
    guard
        let bucket = Environment.process.S3_BUCKET,
        let accessKey = Environment.process.S3_ACCESS_KEY,
        let secretKey = Environment.process.S3_SECRET_KEY,
        let rawRegion = Environment.process.S3_REGION
    else {
        throw Abort(.internalServerError, reason: "Missing S3 environment variable(s)")
    }

    let region = Region(name: .init(rawRegion))
    let config = S3Signer.Config(
        accessKey: accessKey,
        secretKey: secretKey,
        region: region,
        securityToken: Environment.process.S3_SECURITY_TOKEN
    )
    let signer = try S3Signer(config)
    
    try services.instance(S3Client.self, S3(defaultBucket: bucket, signer: signer))
    cache.register(storage: S3Storage.init(container:), slug: "s3")
}
