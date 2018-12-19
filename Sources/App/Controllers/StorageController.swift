import Storage
import Vapor

final class StorageController<S>: RouteCollection where S: Storage {
    let id: String
    let storage: S
    
    init(id: String, storage: S) {
        self.id = id
        self.storage = storage
    }
    
    func boot(router: Router) throws {
        let storage = router.grouped(any, "media-manager", self.id)
        
        storage.post(use: upload)
        storage.get(all, use: get)
        storage.put(all, use: replace)
        storage.delete(all, use: delete)
    }
    
    func upload(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.content.decode(File.self).and(result: Optional<String>.none).flatMap(self.storage.store).transform(to: .ok)
    }
    
    func get(_ request: Request)throws -> Future<HTTPResponse> {
        let filename = self.filename(from: request.http)
        return self.storage.fetch(file: filename).map { HTTPResponse(body: $0.data) }
    }
    
    func replace(_ request: Request)throws -> Future<HTTPStatus> {
        let filename = self.filename(from: request.http)
        let data = request.content.get(Data.self, at: "data")
        
        return data.flatMap { contents in
            return self.storage.write(file: filename, with: contents, options: [])
        }.transform(to: .ok)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let filename = self.filename(from: request.http)
        return self.storage.delete(file: filename).transform(to: .noContent)
    }
    
    private func filename(from request: HTTPRequest) -> String {
        let path = request.url.path
        let components = path.split(separator: "/").map(String.init)
        return components.drop { $0 != self.id }.dropFirst().joined(separator: "/")
    }
}
