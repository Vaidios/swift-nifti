import Foundation


public final class SwiftyNifti {
    
    private init() { }
    
    public static func getHeader(for url: URL) throws -> NiftiHeaderV1 {
        guard let fileBytes = FileHandle.readHeaderBytes(from: url) else {
            throw SwiftyNiftiError.invalidStringPath
        }
        let niftiBinReader = NiftiV1BinaryReader(data: fileBytes)
        
        do {
            let header = try niftiBinReader.getHeader()
            return header
        } catch {
            throw error
        }
        
    }
    
    public static func getData(for url: URL) throws -> [[[PixelData]]] {
        do {
            let fileBytes = try FileHandle(forReadingFrom: url).availableData
            let niftiBinReader = NiftiV1BinaryReader(data: fileBytes)
            let header = try niftiBinReader.getHeader()
            let pixeldata = try niftiBinReader.getPixelData(using: header)
            return pixeldata
        } catch {
            throw error
        }
    }
    
    public static func getYFlippedData(for url: URL) throws {
        
        do {
            let data = try Self.getData(for: url)
            
            
            
            
        } catch {
            throw error
        }
    }
}
