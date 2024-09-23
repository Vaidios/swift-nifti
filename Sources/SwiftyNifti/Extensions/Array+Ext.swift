import Foundation

extension Array where Element == UInt8 {
  func bytesToHex(spacing: String) -> String {
    var hexString: String = ""
    var count = self.count
    for byte in self {
      hexString.append(String(format:"%02X", byte))
      count = count - 1
      if count > 0 {
        hexString.append(spacing)
      }
    }
    return hexString
  }
}
