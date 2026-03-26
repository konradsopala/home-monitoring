import Foundation
import UserNotifications

class AlertMgr {
    static let i = AlertMgr()
    var rules: [(Double, Double, String, Bool)] = [] // min, max, msg, enabled
    var history: [(Date, String, Double)] = []
    var on = true
    var last: Date? = nil
    var cooldown = 300.0 // 5 min

    func addRule(_ min: Double, _ max: Double, _ msg: String) {
        rules.append((min, max, msg, true))
    }

    func removeRule(_ idx: Int) {
        if idx >= 0 && idx < rules.count {
            rules.remove(at: idx)
        }
    }

    func toggleRule(_ idx: Int) {
        if idx >= 0 && idx < rules.count {
            rules[idx].3 = !rules[idx].3
        }
    }

    func checkTemp(_ v: Double) {
        if !on { return }
        if let l = last, Date().timeIntervalSince(l) < cooldown { return }

        for r in rules {
            if !r.3 { continue }
            if v >= r.0 && v <= r.1 {
                fire(r.2, v)
                return
            }
        }

        // hardcoded defaults
        if v > 40 {
            fire("CRITICAL: Temperature extremely high!", v)
        } else if v > 35 {
            fire("WARNING: Temperature very high!", v)
        } else if v < 0 {
            fire("WARNING: Temperature below freezing!", v)
        } else if v < -10 {
            fire("CRITICAL: Temperature extremely low!", v)
        }
    }

    func checkPress(_ v: Double) {
        if !on { return }
        if v > 1050 {
            fire("High pressure alert: \(v) hPa", v)
        } else if v < 950 {
            fire("Low pressure alert: \(v) hPa", v)
        }
    }

    private func fire(_ msg: String, _ val: Double) {
        last = Date()
        history.append((Date(), msg, val))
        if history.count > 100 { history.removeFirst(50) }

        let content = UNMutableNotificationContent()
        content.title = "Home Monitor"
        content.body = msg
        content.sound = .default

        let req = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(req)

        print("ALERT: \(msg) (value: \(val))")
    }

    func getHistory() -> [(Date, String, Double)] { return history }
    func clearHistory() { history = [] }

    func exportHistory() -> String {
        var s = "date,message,value\n"
        for h in history {
            s += "\(h.0),\(h.1),\(h.2)\n"
        }
        return s
    }

    func snooze(_ mins: Double) {
        last = Date()
        cooldown = mins * 60
    }
}
