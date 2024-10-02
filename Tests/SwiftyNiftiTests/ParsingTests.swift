import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct ParsingTests {
  
  @Test
  func testHeader() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    #expect(header.dim[0] == 3)
    #expect(header.dim[1] == 64)
    #expect(header.dim[2] == 64)
    #expect(header.dim[3] == 10)
  }
  
  @Test
  func testVolume() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    #expect(volume.voxels.count == 40960)
  }
  
  @Test
  func testPlane() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    let plane = volume.getCoronalPlane(z: 1)
    #expect(plane.count == 4096)
  }
  
  func getExampleURL() throws -> URL {
    try #require(Bundle.module.url(forResource: "minimal", withExtension: "nii"))
  }
}
