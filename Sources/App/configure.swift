//import FluentSQLite
import Vapor
import S3

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
    // Git message:
    let accessKey = Environment.get("AWSACCESSKEY")
    let secretKey = Environment.get("AWSSECRETKEY")
    let region = Region.euCentral1
    try services.register(s3: S3Signer.Config(accessKey: accessKey!,
                                              secretKey: secretKey!,
                                              region: region),
                          defaultBucket: "bucket-inuk")
    
    // Configure a SQLite database
   // let sqlite = try SQLiteDatabase(storage: .memory)

    /// Register the configured SQLite database to the database config.
    //var databases = DatabasesConfig()
    //databases.add(database: sqlite, as: .sqlite)
    //services.register(databases)

    /// Configure migrations
    //var migrations = MigrationConfig()
    //migrations.add(model: Todo.self, database: .sqlite)
    //services.register(migrations)

}
