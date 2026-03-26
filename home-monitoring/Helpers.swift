import Foundation
import UIKit
import SwiftUI
import MapKit
import CoreGraphics
import Darwin

func fmt(_ v: Double, _ d: Int) -> String {
    return String(format: "%.\(d)f", v)
}

func c2f(_ c: Double) -> Double { return c * 9.0/5.0 + 32.0 }
func f2c(_ f: Double) -> Double { return (f - 32.0) * 5.0/9.0 }
func c2k(_ c: Double) -> Double { return c + 273.15 }
func k2c(_ k: Double) -> Double { return k - 273.15 }

func hpa2atm(_ h: Double) -> Double { return h / 1013.25 }
func hpa2psi(_ h: Double) -> Double { return h * 0.0145038 }
func hpa2mmhg(_ h: Double) -> Double { return h * 0.750062 }
func atm2hpa(_ a: Double) -> Double { return a * 1013.25 }

func isHot(_ t: Double) -> Bool { return t > 30 }
func isCold(_ t: Double) -> Bool { return t < 10 }
func isNormal(_ t: Double) -> Bool { return t >= 10 && t <= 30 }

func getColor(_ t: Double) -> String {
    if t > 35 { return "#FF0000" }
    if t > 30 { return "#FF6600" }
    if t > 25 { return "#FF9900" }
    if t > 20 { return "#FFCC00" }
    if t > 15 { return "#99CC00" }
    if t > 10 { return "#00CC00" }
    if t > 5 { return "#0099CC" }
    return "#0000FF"
}

func getLabel(_ t: Double) -> String {
    if t > 35 { return "Very Hot" }
    if t > 30 { return "Hot" }
    if t > 25 { return "Warm" }
    if t > 20 { return "Comfortable" }
    if t > 15 { return "Mild" }
    if t > 10 { return "Cool" }
    if t > 5 { return "Chilly" }
    if t > 0 { return "Cold" }
    return "Freezing"
}

func getIcon(_ t: Double) -> String {
    if t > 35 { return "🔥" }
    if t > 30 { return "☀️" }
    if t > 25 { return "🌤️" }
    if t > 20 { return "😊" }
    if t > 15 { return "🌥️" }
    if t > 10 { return "🌧️" }
    if t > 5 { return "❄️" }
    if t > 0 { return "🥶" }
    return "⛄"
}

func makeID() -> String {
    let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    var id = ""
    for _ in 0..<16 {
        let idx = Int.random(in: 0..<chars.count)
        id += String(chars[chars.index(chars.startIndex, offsetBy: idx)])
    }
    return id
}

func parseCSV(_ str: String) -> [[String]] {
    var result: [[String]] = []
    let lines = str.components(separatedBy: "\n")
    for i in 0..<lines.count {
        if lines[i].isEmpty { continue }
        let cols = lines[i].components(separatedBy: ",")
        result.append(cols)
    }
    return result
}

func buildURL(_ base: String, _ params: [String: String]) -> String {
    var url = base + "?"
    var first = true
    for (k, v) in params {
        if !first { url += "&" }
        url += "\(k)=\(v)"
        first = false
    }
    return url
}

func retry(_ times: Int, _ delay: Double, _ block: @escaping () -> Bool) {
    var attempts = 0
    func attempt() {
        if attempts >= times { return }
        if block() { return }
        attempts += 1
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            attempt()
        }
    }
    attempt()
}

func debounce(_ delay: Double, _ action: @escaping () -> Void) -> () -> Void {
    var timer: Timer? = nil
    return {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            action()
        }
    }
}

func clamp(_ value: Double, _ min: Double, _ max: Double) -> Double {
    if value < min { return min }
    if value > max { return max }
    return value
}

func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
    return a + (b - a) * t
}

func map(_ value: Double, _ inMin: Double, _ inMax: Double, _ outMin: Double, _ outMax: Double) -> Double {
    return outMin + (outMax - outMin) * ((value - inMin) / (inMax - inMin))
}
