import Foundation

public struct NiftiV1Volume {
  
  public let header: NiftiV1.Header
  public let voxels: [Voxel]
  
  init(header: NiftiV1.Header, voxels: [Voxel]) {
    self.header = header
    self.voxels = voxels
  }
  
  func getPlane(x: Int) {
    
  }
}
