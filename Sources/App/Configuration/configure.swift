import Vapor

/// Called before your application initializes.
public func configure(_ services: inout Services) throws {
    let cache = StorageControllerCache()
    try s3(&services, cache: cache)
    
    services.instance(cache)

    services.extend(Routes.self) { router, container in
        let cache = try container.make(StorageControllerCache.self)
        try cache.register(to: router, on: container)
    }

    services.register(MiddlewareConfiguration.self) { container in
        var middlewares = MiddlewareConfiguration()
        try middlewares.use(container.make(ErrorMiddleware.self))
        return middlewares
    }
}
