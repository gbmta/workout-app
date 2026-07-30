import Foundation

func formatWeight(_ weight: Double?, isBodyweight: Bool) -> String {
    if isBodyweight { return "BW" }
    guard let weight else { return "?" }
    return weight.truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(weight))
        : String(weight)
}
