import SwiftyNiftiCore
import Foundation

let tool = SwiftyNifti(stringPath: "/Users/vaidios/Downloads/minimal.nii")
tool.printHeader()
tool.readData()
