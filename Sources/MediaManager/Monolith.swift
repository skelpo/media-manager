import Vapor
import Foundation
import S3


/*
protocol MediaManager {
    
    func upload(file: Core.File, req: Request)
    
    func delete(file: String) -> Void
    
    func update(file: Core.File) -> Void
    
}
/*
protocol FileProtocol {
    
    var data: Data { get }
    
    var mediaType: Core.File.Type { get }
}
*/
class S3Provider: MediaManager {
    
    func upload(file: Core.File) { req -> Future<String> in
        var s3File = File.init(data: file.data, filename: file.filename)
        let s3 = try req.makeS3Client()
        do {
            return /*try*/ s3.put(file: s3File.Upload, on: req)
        } catch {
            print(error)
            fatalError!
        }
    }
    
    func update(file: Core.File) {
        <#code#>
    }
    
    func delete(file: String) {
        <#code#>
    }
    
    
    
    
    /*init(parameters) {
        <#statements#>
    }*/
}

*/
