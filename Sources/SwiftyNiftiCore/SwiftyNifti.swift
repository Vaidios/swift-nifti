import Foundation


public final class SwiftyNifti {
    
    private var url: URL
    
    var niftiHeader: NiftiHeaderV1?

    convenience public init(stringPath: String) {
        let url = URL(fileURLWithPath: stringPath)
        self.init(url: url)
    }
    
    public init(url: URL) {
        self.url = url
    }
    
    public func run() {
        print(url.path)
    }
    public func printHeader() {
        guard let headerBytes = FileHandle.readHeaderBytes(from: url) else {
            fatalError("Could not read header bytes from specified url")
        }
        let binReader = BinaryReader(data: headerBytes)
        
        do {
            niftiHeader = try binReader.getNiftiV1HeaderInfo()
            print(niftiHeader!)
        } catch {
            print(error)
        }
    }
    
    public func readData() {
        guard let nim = niftiHeader else { fatalError("No image avilable") }
        
        switch nim.niftiDatatype {
        case .uint8:
            var arr = [[[UInt8]]].init(repeating: [[UInt8]].init(repeating: [UInt8].init(repeating: 0, count: nim.nz), count: nim.ny), count: nim.nx)
//            let url = URL(string: stringPath!)!
            let binReader = try! BinaryReader(data: FileHandle(forReadingFrom: url).availableData)
            binReader.readSpacialData(using: nim, into: &arr)
            print("First row \(arr.first!.first!)")
            for slice in arr {
                for line in slice {
                    print(line)
                }
                print("")
            }
        default:
            fatalError("Data type not supported by SwiftyNifti")
        }
    }
}

public extension SwiftyNifti {
    enum Error: Swift.Error {
        case invalidStringPath
    }
}
