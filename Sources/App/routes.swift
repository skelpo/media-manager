import Vapor
import S3
import Foundation
/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    let s3Routes = router.grouped("s3")
    
    func postS3(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Filer.self).flatMap { filer in
            let file = filer.file
            //print(file.filename)
            let s3 = try req.makeS3Client()
            let string = file.data.base32EncodedString()
            print(string)
            let fileName = file.filename
            return try s3.put(string: string, destination: fileName, access: .publicRead, on: req)
                .map(to: Response.self) {_ in
                    return req.redirect(to: "")
            }
        }
        
    }
    
    s3Routes.post("post", use: postS3)
    
    
}

struct Filer: Codable
{
    let conformance: String?
    let file: Core.File
}
