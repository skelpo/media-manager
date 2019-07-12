import Storage
import Vapor

final class StorageController<S>: RouteCollection where S: Storage {
    let id: String
    let storage: S
    
    init(id: String, storage: S) {
        self.id = id
        self.storage = storage
    }
    
    func boot(routes: RoutesBuilder) throws {
        let storage = routes.grouped(.anything, "media-manager", .constant(self.id))
        
        storage.post(use: upload)
        storage.get(.catchall, use: get)
        storage.put(.catchall, use: replace)
        storage.delete(.catchall, use: delete)
    }
    
    func upload(_ request: Request)throws -> EventLoopFuture<HTTPStatus> {
        let file = try request.content.decode(File.self)
        return self.storage.store(file: file, at: nil).transform(to: .ok)
    }
    
    func get(_ request: Request)throws -> EventLoopFuture<Response> {
        let filename = self.filename(from: request)
        return self.storage.fetch(file: filename).map { Response(body: .init(data: Data($0.data.readableBytesView))) }
    }
    
    func replace(_ request: Request)throws -> EventLoopFuture<HTTPStatus> {
        let filename = self.filename(from: request)
        let data = try request.content.get(Data.self, at: "data")
        return self.storage.write(file: filename, with: data).transform(to: .ok)
    }
    
    func delete(_ request: Request)throws -> EventLoopFuture<HTTPStatus> {
        let filename = self.filename(from: request)
        return self.storage.delete(file: filename).transform(to: .noContent)
    }
    
    private func filename(from request: Request) -> String {
        let path = request.url.path
        let components = path.split(separator: "/").map(String.init)
        return components.drop { $0 != self.id }.dropFirst().joined(separator: "/")
    }
}
