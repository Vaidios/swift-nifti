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
    
    public static func getVolume(for url: URL) throws -> NiftiVolume {
        do {
            let fileBytes = try FileHandle(forReadingFrom: url).availableData
            let niftiBinReader = NiftiV1BinaryReader(data: fileBytes)
            let header = try niftiBinReader.getHeader()
            let pixeldata = try niftiBinReader.getPixelData(using: header)
            
            let volume = NiftiVolume(header: header, data: pixeldata)
            
            return volume
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
    
    public class NiftiVolume {
        
        public let header: NiftiHeaderV1
        
        private let originalData: [[[PixelData]]]
        private var axialData: [[[PixelData]]]?
        private var coronalData: [[[PixelData]]]?
        
        internal init(header: NiftiHeaderV1, data: [[[PixelData]]]) {
            self.header = header
            self.originalData = data
        }
        
        public func getSagittalData() -> [[[PixelData]]] {
            return originalData
        }
        
        public func getAxialData() -> [[[PixelData]]] {
            if let axialData = self.axialData { return axialData }
            var arr = SwiftyNifti.getEmptyPixelArr(nx: header.nz, ny: header.ny, nz: header.nx)
            for x in 0 ..< header.nx {
                for y in 0 ..< header.ny {
                    for z in 0 ..< header.nz {
                        arr[z][y][x] = originalData[x][y][z]
                    }
                }
            }
            self.axialData = arr
            return arr
        }
        
        public func getCoronalData() -> [[[PixelData]]] {
            if let coronalData = self.coronalData { return coronalData }
            var arr = SwiftyNifti.getEmptyPixelArr(nx: header.ny, ny: header.nx, nz: header.nz)
            
            for z in 0 ..< header.nz {
                for x in 0 ..< header.nx {
                    for y in 0 ..< header.ny {
                        arr[y][x][z] = originalData[x][y][z]
                    }
                }
            }
            self.coronalData = arr
            return arr
        }
    }
}
