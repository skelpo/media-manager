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
        let storage = router.grouped(self.id)
        
        storage.post("upload", use: upload)
        storage.get("get", use: get)
        storage.put("replace", use: replace)
        storage.delete("delete", use: delete)
    }
    
    func upload(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.content.decode(File.self).and(result: Optional<String>.none).flatMap(self.storage.store).transform(to: .ok)
    }
    
    func get(_ request: Request)throws -> Future<HTTPResponse> {
        return try request.content.decode(FileName.self).map { $0.name }.flatMap(self.storage.fetch).map { HTTPResponse(body: $0.data) }
    }
    
    func replace(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.content.decode(FileUpdate.self).map(FileUpdate.tuple).flatMap(self.storage.write).transform(to: .ok)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.content.decode(FileName.self).map { $0.name }.flatMap(self.storage.delete).transform(to: .noContent)
    }
}

struct FileName: Content {
    let name: String
}

struct FileUpdate: Content {
    let name: String
    let contents: Data
    let options: Data.WritingOptions = []
    
    static func tuple(update: FileUpdate) -> (String, Data, Data.WritingOptions) {
        return (update.name, update.contents, update.options)
    }
}

extension Data.WritingOptions: Codable {}