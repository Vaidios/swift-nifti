import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct HeaderTests {
  
  @Test
  func testHeaderBasicFields() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test basic header fields
    #expect(header.sizeof_hdr == 348)
    #expect(header.ndim == 3)
    #expect(header.nx == 64)
    #expect(header.ny == 64)
    #expect(header.nz == 10)
    #expect(header.nt == 1)
    #expect(header.nu == 1)
    #expect(header.nv == 1)
    #expect(header.nw == 1)
  }
  
  @Test
  func testHeaderDimensions() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test dimensions array
    #expect(header.dim.count == 8)
    #expect(header.dim[0] == 3) // number of dimensions
    #expect(header.dim[1] == 64) // x dimension
    #expect(header.dim[2] == 64) // y dimension
    #expect(header.dim[3] == 10) // z dimension
    #expect(header.dim[4] == 1) // time dimension
    #expect(header.dim[5] == 1) // u dimension
    #expect(header.dim[6] == 1) // v dimension
    #expect(header.dim[7] == 1) // w dimension
  }
  
  @Test
  func testHeaderVolumeDimensions() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test volume dimensions struct
    let dimensions = header.dimensions
    #expect(dimensions.nx == 64)
    #expect(dimensions.ny == 64)
    #expect(dimensions.nz == 10)
  }
  
  @Test
  func testHeaderDataType() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test data type information
    #expect(header.datatype > 0)
    #expect(header.bitpix > 0)
    #expect(header.bytesPerVoxel > 0)
    #expect(!header.datatypeString.isEmpty)
  }
  
  @Test
  func testHeaderPixelDimensions() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test pixel dimensions
    #expect(header.pixdim.count == 8)
    #expect(header.dx > 0)
    #expect(header.dy > 0)
    #expect(header.dz > 0)
    #expect(header.dt >= 0)
    #expect(header.du >= 0)
    #expect(header.dv >= 0)
    #expect(header.dw >= 0)
  }
  
  @Test
  func testHeaderIntentInformation() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test intent information
    #expect(header.intent_code >= 0)
    #expect(header.intent_p1.isFinite)
    #expect(header.intent_p2.isFinite)
    #expect(header.intent_p3.isFinite)
    #expect(!header.intent_nameString.isEmpty)
  }
  
  @Test
  func testHeaderScalingInformation() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test scaling information
    #expect(header.scl_slope.isFinite)
    #expect(header.scl_inter.isFinite)
    #expect(header.cal_max.isFinite)
    #expect(header.cal_min.isFinite)
  }
  
  @Test
  func testHeaderSliceInformation() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test slice information
    #expect(header.slice_start >= 0)
    #expect(header.slice_end >= 0)
    #expect(header.slice_duration >= 0)
    #expect(header.toffset.isFinite)
  }
  
  @Test
  func testHeaderTransformInformation() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test transform information
    #expect(header.qform_code >= 0)
    #expect(header.sform_code >= 0)
    #expect(header.quatern_b.isFinite)
    #expect(header.quatern_c.isFinite)
    #expect(header.quatern_d.isFinite)
    #expect(header.qoffset_x.isFinite)
    #expect(header.qoffset_y.isFinite)
    #expect(header.qoffset_z.isFinite)
  }
  
  @Test
  func testHeaderSRowMatrices() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test srow matrices
    #expect(header.srow_x.count == 4)
    #expect(header.srow_y.count == 4)
    #expect(header.srow_z.count == 4)
    
    // All srow values should be finite
    for value in header.srow_x { #expect(value.isFinite) }
    for value in header.srow_y { #expect(value.isFinite) }
    for value in header.srow_z { #expect(value.isFinite) }
  }
  
  @Test
  func testHeaderMetadata() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test metadata fields
    #expect(header.descript.count == 80)
    #expect(header.aux_file.count == 24)
    #expect(header.intent_name.count == 16)
    #expect(header.magic.count == 4)
    
    // Test string conversions
    #expect(header.descriptString.count <= 80)
    #expect(header.intent_nameString.count <= 16)
    #expect(header.magicString.count == 4)
  }
  
  @Test
  func testHeaderGlobalMinMax() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test global min/max values
    #expect(header.glmax >= header.glmin)
  }
  
  @Test
  func testHeaderFileLength() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test file length calculation
    let fileLength = header.fileLength
    #expect(fileLength > 0)
    #expect(fileLength >= Int(header.vox_offset))
  }
  
  @Test
  func testHeaderDataArray() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test data array for display
    let dataArray = header.dataArray
    #expect(!dataArray.isEmpty)
    
    // Check that all required fields are present
    let fieldNames = dataArray.map { $0.0 }
    #expect(fieldNames.contains("Size of header"))
    #expect(fieldNames.contains("Dimension sizes"))
    #expect(fieldNames.contains("Datatype"))
    #expect(fieldNames.contains("Pixel dimensions"))
  }
  
  @Test
  func testHeaderDescription() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test description string
    let description = header.description
    #expect(!description.isEmpty)
    #expect(description.contains("Dimensions"))
    #expect(description.contains("Datatype"))
  }
  
  @Test
  func testHeaderUnits() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test units field
    #expect(header.xyzt_units >= 0)
  }
  
  func getExampleURL() throws -> URL {
    try #require(Bundle.module.url(forResource: "minimal", withExtension: "nii"))
  }
} 