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
    
    public static func getZYFlippedData(for url: URL) throws -> [[[PixelData]]] {
        
        do {
            let header = try Self.getHeader(for: url)
            let data = try Self.getData(for: url)
            var arr = Self.getEmptyPixelArr(nx: header.nz, ny: header.ny, nz: header.nx)
            for x in 0 ..< header.nx {
                for y in 0 ..< header.ny {
                    for z in 0 ..< header.nz {
                        arr[z][y][x] = data[x][y][z]
                    }
                }
            }
            return arr
        } catch {
            throw error
        }
    }
    
    private static func getEmptyPixelArr(nx: Int, ny: Int, nz: Int) -> [[[PixelData]]] {
        let arr = [[[PixelData]]].init(
            repeating: [[PixelData]].init(
                repeating: [PixelData].init(
                    repeating: PixelData(r: 0, g: 0, b: 0), count: nz), count: ny), count: nx)
        return arr
    }
}
