import Vapor
import ServiceExt

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    Environment.dotenv(filename: env.name + ".env")
    
    /// Register providers first

    /// Storage Controllers
    let cache = StorageControllerCache()
    try s3(&services, cache: cache)
    
    services.register(cache)
    
    /// Register routes to the router
    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        let cache = try container.make(StorageControllerCache.self)
        
        try cache.register(to: router, on: container)
        
        return router
    }

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
}
