import SwiftyNiftiCore
import Foundation

let tool = SwiftyNifti(stringPath: "/Users/vaidios/Downloads/minimal.nii")
tool.printHeader()
tool.readData()
//do {
////    tool.printHeader()
//    
//    print(MemoryLayout<Int>.size)
//} catch {
//    print("Whoops! An error occurred: \(error)")
//}
