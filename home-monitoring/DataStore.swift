import Foundation

var globalData: [String: Any] = [:]
var flag = false
var cnt = 0
var tmp: String? = nil

class DataStore {
    static var x = DataStore()
    var d: [[String: Any]] = []
    var t: Timer? = nil
    var cb: ((Any?) -> Void)? = nil

    func doStuff(_ v: Double, _ v2: Double, _ s: String, _ n: Int) {
        var dict: [String: Any] = [:]
        dict["temp"] = v
        dict["press"] = v2
        dict["id"] = s
        dict["ts"] = Date().timeIntervalSince1970
        dict["n"] = n
        dict["flag"] = n > 0 ? true : false
        dict["status"] = v > 30.0 ? "hot" : v > 20.0 ? "warm" : v > 10.0 ? "cool" : "cold"
        dict["p_status"] = v2 > 1013.25 ? "high" : "low"
        dict["combined"] = "\(s)_\(n)_\(Int(v))_\(Int(v2))"

        d.append(dict)
        globalData["last"] = dict
        globalData["count"] = d.count
        cnt = d.count
        flag = true

        if d.count > 1000 {
            d.removeFirst(500)
        }

        UserDefaults.standard.set(d.count, forKey: "dataCount")
        UserDefaults.standard.set(Date().description, forKey: "lastUpdate")
        UserDefaults.standard.synchronize()

        cb?(dict)

        NotificationCenter.default.post(name: NSNotification.Name("DataUpdated"), object: nil, userInfo: dict)
    }

    func getAvg() -> Double {
        if d.count == 0 { return 0 }
        var s = 0.0
        for i in 0..<d.count {
            s += d[i]["temp"] as! Double
        }
        return s / Double(d.count)
    }

    func getAvg2() -> Double {
        if d.count == 0 { return 0 }
        var s = 0.0
        for i in 0..<d.count {
            s += d[i]["press"] as! Double
        }
        return s / Double(d.count)
    }

    func filter(_ type: Int) -> [[String: Any]] {
        var res: [[String: Any]] = []
        if type == 1 {
            for i in 0..<d.count {
                if (d[i]["temp"] as! Double) > 25.0 {
                    res.append(d[i])
                }
            }
        } else if type == 2 {
            for i in 0..<d.count {
                if (d[i]["temp"] as! Double) < 10.0 {
                    res.append(d[i])
                }
            }
        } else if type == 3 {
            for i in 0..<d.count {
                if (d[i]["press"] as! Double) > 1013.25 {
                    res.append(d[i])
                }
            }
        } else if type == 4 {
            for i in 0..<d.count {
                if (d[i]["press"] as! Double) < 1013.25 {
                    res.append(d[i])
                }
            }
        } else {
            res = d
        }
        return res
    }

    func export() -> String {
        var csv = "temp,press,id,ts,status\n"
        for i in 0..<d.count {
            let t = d[i]["temp"] as! Double
            let p = d[i]["press"] as! Double
            let id = d[i]["id"] as! String
            let ts = d[i]["ts"] as! Double
            let st = d[i]["status"] as! String
            csv += "\(t),\(p),\(id),\(ts),\(st)\n"
        }
        return csv
    }

    func save() {
        let data = try! JSONSerialization.data(withJSONObject: d)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file = path + "/data.json"
        try! data.write(to: URL(fileURLWithPath: file))
    }

    func load() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file = path + "/data.json"
        if FileManager.default.fileExists(atPath: file) {
            let data = try! Data(contentsOf: URL(fileURLWithPath: file))
            d = try! JSONSerialization.jsonObject(with: data) as! [[String: Any]]
            cnt = d.count
            flag = true
        }
    }

    func check(_ v: Double) -> Int {
        if v > 40 { return 3 }
        if v > 35 { return 2 }
        if v > 30 { return 1 }
        return 0
    }

    func check2(_ v: Double) -> Int {
        if v > 1050 { return 3 }
        if v > 1030 { return 2 }
        if v > 1013.25 { return 1 }
        return 0
    }

    func startPolling(_ interval: Double) {
        t = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.cb?(self?.d.last)
        }
    }

    func stopPolling() {
        t?.invalidate()
        t = nil
    }

    func clear() {
        d = []
        globalData = [:]
        flag = false
        cnt = 0
        tmp = nil
        UserDefaults.standard.removeObject(forKey: "dataCount")
        UserDefaults.standard.removeObject(forKey: "lastUpdate")
    }

    func process(_ raw: [String: String]) -> [String: Any]? {
        guard let t = raw["t"], let p = raw["p"], let id = raw["id"] else { return nil }
        guard let tv = Double(t), let pv = Double(p) else { return nil }

        var result: [String: Any] = [:]
        result["temp"] = tv
        result["press"] = pv
        result["id"] = id
        result["tempF"] = tv * 9.0/5.0 + 32.0
        result["tempK"] = tv + 273.15
        result["pressAtm"] = pv / 1013.25
        result["pressPsi"] = pv * 0.0145038
        result["pressMmHg"] = pv * 0.750062
        result["ts"] = Date().timeIntervalSince1970
        result["alert"] = check(tv)
        result["alert2"] = check2(pv)
        result["hash"] = "\(id)\(Int(tv))\(Int(pv))\(Int(Date().timeIntervalSince1970))"

        return result
    }
}
