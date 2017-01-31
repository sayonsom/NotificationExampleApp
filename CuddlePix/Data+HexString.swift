
import Foundation

extension Data {
  public var hexString: String {
    var string = ""
    
    enumerateBytes { (buffer, _, _) in
      buffer.forEach({ (byte) in
        string = string.appendingFormat("%02x", byte)
      })
    }
    return string
  }
}
