import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct ParsingTests {
  
  @Test
  func testHeader() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header
    #expect(header.dim[0] == 3)
    #expect(header.dim[1] == 64)
    #expect(header.dim[2] == 64)
    #expect(header.dim[3] == 10)
  }
  
  func getExampleURL() throws -> URL {
    try #require(Bundle.module.url(forResource: "minimal", withExtension: "nii"))
  }
}
