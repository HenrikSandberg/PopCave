import Foundation

extension TimeInterval {
    var minutesAndSecoundsString: String {
        return String(format:"%d:%02d", minute, second)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
}

extension Int {
    var milisToSecounds: Double {
        return Double(self) / 1000
    }
}

extension String {
    var toUrlString: String {
        var nameStr = self.lowercased()
        nameStr = nameStr.replacingOccurrences(of: " ", with: "%20")
        nameStr = nameStr.replacingOccurrences(of: "!", with: "%21")
        nameStr = nameStr.replacingOccurrences(of: "#", with: "%23")
        nameStr = nameStr.replacingOccurrences(of: "%", with: "%25")
        nameStr = nameStr.replacingOccurrences(of: "&", with: "%26")
        nameStr = nameStr.replacingOccurrences(of: "(", with: "%28")
        nameStr = nameStr.replacingOccurrences(of: ")", with: "%29")
        nameStr = nameStr.replacingOccurrences(of: "*", with: "%2A")
        nameStr = nameStr.replacingOccurrences(of: "+", with: "%2B")
        nameStr = nameStr.replacingOccurrences(of: ".", with: "%2E")
        nameStr = nameStr.replacingOccurrences(of: "-", with: "%2D")
        nameStr = nameStr.replacingOccurrences(of: ",", with: "%2C")
        nameStr = nameStr.replacingOccurrences(of: "$", with: "%24")
        nameStr = nameStr.replacingOccurrences(of: ":", with: "%3A")
        nameStr = nameStr.replacingOccurrences(of: ";", with: "%3B")
        nameStr = nameStr.replacingOccurrences(of: "<", with: "%3C")
        nameStr = nameStr.replacingOccurrences(of: "=", with: "%3D")
        nameStr = nameStr.replacingOccurrences(of: ">", with: "%3E")
        nameStr = nameStr.replacingOccurrences(of: "?", with: "%3F")
        nameStr = nameStr.replacingOccurrences(of: "@", with: "%40")
        nameStr = nameStr.replacingOccurrences(of: "\"", with: "%22")
        nameStr = nameStr.replacingOccurrences(of: "'", with: "%27")
        
        
        return nameStr
    }
}
