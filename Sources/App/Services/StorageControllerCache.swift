import Storage
import Vapor

final class StorageControllerCache {
    private var factories: [String: (Container)throws -> RouteCollection] = [:]
    
    func register<S>(storage initializer: @escaping (Container)throws -> S, slug: String) where S: Storage {
        let factory = { (container: Container)throws -> StorageController<S> in
            let storage = try initializer(container)
            let controller = StorageController<S>.init(id: slug, storage: storage)
            
            return controller
        }
        
        self.factories[String(describing: S.self)] = factory
    }
    
    func register(to router: RoutesBuilder, on container: Container)throws {
        let factories = self.factories.values
        let controllers = try factories.map { factory in try factory(container) }
        
        try controllers.forEach(router.register(collection:))
    }
}
