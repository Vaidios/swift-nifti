enum NiftiV1Error: Error {
  case invalidDimensions
  case invalidHeaderSize
  case unsupportedDataFormat
}
