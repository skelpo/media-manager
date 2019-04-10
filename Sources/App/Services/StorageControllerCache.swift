import Storage
import Vapor

final class StorageControllerCache: Service {
    private var factories: [String: (Container)throws -> RouteCollection] = [:]
    
    func register<S>(storage: S.Type, slug: String) where S: Storage & ServiceType {
        let factory = { (container: Container)throws -> StorageController<S> in
            let storage = try storage.makeService(for: container)
            let controller = StorageController<S>.init(id: slug, storage: storage)
            
            return controller
        }
        
        self.factories[String(describing: S.self)] = factory
    }
    
    func register(to router: Router, on container: Container)throws {
        let factories = self.factories.values
        let controllers = try factories.map { factory in try factory(container) }
        
        try controllers.forEach(router.register(collection:))
    }
}
