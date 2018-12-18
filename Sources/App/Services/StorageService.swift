import Storage
import Vapor

extension Services {
    mutating func registerStorage<S>(_ service: S.Type, slug: String) where S: Storage & ServiceType {
        self.register(factory: { (container: Container)throws -> S in
            let storage = try S.makeService(for: container)
            
            let router = try container.make(Router.self)
            try router.register(collection: StorageController<S>.init(id: slug, storage: storage))
            
            return storage
        })
    }
}
