import Vapor
import S3
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
            let file = File.Upload(data: filer.file.data, destionation: filer.file.filename, access: .publicRead, mime: filer.file.contentType?.description)
            return try req.makeS3Client().put(file: file, on: req)
                .map(to: Response.self) {_ in
                    return req.redirect(to: "")
            }
        }
        
    }
    
    s3Routes.post("post", use: postS3)
    
    
}

struct Filer: Content
{
    let file: Core.File
}
