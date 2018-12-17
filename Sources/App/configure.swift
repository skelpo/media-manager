import Vapor
import ServiceExt

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    //try services.register(FluentSQLiteProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    
    Environment.dotenv()
    if Environment.get("CLOUDPROVIDER") == "aws" {
        guard let accessKey: String = Environment.get("AWSACCESSKEY"), let secretKey: String = Environment.get("AWSSECRETKEY") else {
            throw Abort(.internalServerError, reason: "AWS environment variables missing")
        }
        print(accessKey)
        
        let region = Region.euCentral1
        try services.register(s3: S3Signer.Config(accessKey: accessKey,
                                                  secretKey: secretKey,
                                                  region: region),
                              defaultBucket: "bucket-inuk")
    }
    else if Environment.get("CLOUDPROVIDER") == "b2" {
        guard let applicationKey: String = Environment.get("B2APPLICATIONKEY"), let keyID: String = Environment.get("B2KEYID") else {
            throw Abort(.internalServerError, reason: "B2 environment variables missing")
        }
        let B2Creds = B2Config(keyID: keyID,
                               applicationID: applicationKey,
                               bucketID: "c57dae5326d7b3ac66660118")
        services.register(B2Creds)
        services.register(B2.self)
    }

}
