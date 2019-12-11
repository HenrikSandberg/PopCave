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
