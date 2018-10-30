import Vapor
import S3
import B2
//rimport Foundation
/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    let s3Routes = router.grouped("s3")
    
    func postS3(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Filer.self).flatMap { filer in
            let mimeType = filer.file.contentType?.description ?? MediaType.plainText.description
            let file = File.Upload(data: filer.file.data, destination: filer.file.filename, access: .publicRead, mime: mimeType)
            return try req.makeS3Client().put(file: file, on: req).map(to: Response.self) {_ in
                    return req.redirect(to: "")
            }
        }
    }
    
    func deletes3(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Delete.self).flatMap { response in
            return try req.makeS3Client().delete(file: response.file as LocationConvertible, on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    s3Routes.post("post", use: postS3)
    
    s3Routes.delete("delete", use: deletes3)
    
    let b2Routes = router.grouped("b2")

    func postB2(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Filer.self).flatMap { filer in
            let file = filer.file
            
            return try req.make(B2.self).upload(file: file).map {_ in
                return req.redirect(to: "")
            }
        }
    }
    b2Routes.post("post", use: postB2)
}

struct Filer: Content
{
    let file: Core.File
}

struct Delete: Content {
    let file: String
}
