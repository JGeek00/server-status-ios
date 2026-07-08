import Foundation

// MARK: - Status
struct StatusModel: Codable {
    let storage: [Storage]?
    let network: Network?
    let memory: Memory?
    let cpu: CPU?
    let host: Host?
}

// MARK: - CPU
struct CPU: Codable {
    let count: Int?
    let utilisation: Double?
    let model: String?
    let cores, cache: Int?
    let cpuCores: [CPUCore]?
    let temperature: [Int]?
}

// MARK: - CPU Core
struct CPUCore: Codable {
    let frequencies: Frequency?
}

// MARK: - Frequency
struct Frequency: Codable {
    let base, max, now, min: Int?
}

// MARK: - Host
struct Host: Codable {
    let uptime: Double?
    let os, hostname: String?
    let loadavg: [Double]?
    let appMemory: String?
    
    enum CodingKeys: String, CodingKey {
        case uptime, os, hostname, loadavg
        case appMemory = "app_memory"
    }
}

// MARK: - Memory
struct Memory: Codable {
    let cached, processes, swapAvailable, swapTotal: Int?
    let total, available: Int?
    
    enum CodingKeys: String, CodingKey {
        case cached, processes
        case swapAvailable = "swap_available"
        case swapTotal = "swap_total"
        case total, available
    }
}

// MARK: - Network
struct Network: Codable {
    let speed: Int?
    let interface: String?
    let rx, tx: Int?
}

// MARK: - Storage
struct Storage: Codable {
    let name: String?
    let total: Double?
    let icon: String?
    let available: Int?
}


func transformStatusJSON(input: Any) -> [String: Any] {
    guard let jsonObject = input as? [String: Any] else { return [:] }
    var output: [String: Any] = [:]

    // CPU
    if let cpu = jsonObject["cpu"] as? [String: Any] {
        var cpuCopy = cpu
        var coresData: [[String: Any]] = []

        let temperatures = cpu["temperatures"] as? [String: Any]
        let frequencies = cpu["frequencies"] as? [String: Any]

        var genericTemp: [Int]?
        if let temperatures = temperatures {
            let toInts: (Any?) -> [Int]? = { value in
                if let arr = value as? [Int] { return arr }
                if let arr = value as? [Double] { return arr.map { Int($0.rounded()) } }
                return nil
            }
            if let tctl = toInts(temperatures["Tctl"]), !tctl.isEmpty {
                genericTemp = tctl
            } else {
                var firsts: [Int] = []
                var lasts: [Int] = []
                for (_, value) in temperatures {
                    guard let arr = toInts(value), arr.count >= 2 else { continue }
                    firsts.append(arr[0])
                    lasts.append(arr[arr.count - 1])
                }
                if !firsts.isEmpty, !lasts.isEmpty {
                    genericTemp = [firsts.max() ?? 0, lasts.max() ?? 0]
                }
            }
        }

        if let frequencies = frequencies {
            // Sort frequencies by cpu number
            let sortedFrequencies = frequencies
                .compactMap { (key, value) -> (Int, String, Any)? in
                    if let num = Int(key.replacingOccurrences(of: "cpu", with: "")) {
                        return (num, key, value)
                    }
                    return nil
                }
                .sorted { $0.0 < $1.0 }

            for (_, freqKey, freqValue) in sortedFrequencies {
                var coreData: [String: Any] = [:]

                if let freqDict = freqValue as? [String: Any] {
                    var freqIntDict: [String: Int] = [:]
                    for (k, v) in freqDict {
                        if let vInt = v as? Int {
                            freqIntDict[k] = vInt
                        }
                    }
                    coreData["frequencies"] = freqIntDict
                }
                coresData.append(coreData)
            }
        }

        cpuCopy.removeValue(forKey: "frequencies")
        cpuCopy.removeValue(forKey: "temperatures")
        cpuCopy["cpuCores"] = coresData
        if let genericTemp = genericTemp {
            cpuCopy["temperature"] = genericTemp
        }
        output["cpu"] = cpuCopy
    }

    // Memory
    if let memory = jsonObject["memory"] as? [String: Any] {
        output["memory"] = memory
    }

    // Storage
    if let storage = jsonObject["storage"] as? [String: Any] {
        var convertedStorage: [[String: Any]] = []
        // sort keys alphabetically
        let sortedKeys = storage.keys.sorted()
        for key in sortedKeys {
            if let value = storage[key] {
                var storageItem: [String: Any] = ["name": key]
                if let valueObj = value as? [String: Any] {
                    for (innerKey, innerValue) in valueObj {
                        storageItem[innerKey] = innerValue
                    }
                }
                convertedStorage.append(storageItem)
            }
        }
        output["storage"] = convertedStorage
    }

    // Network
    if let network = jsonObject["network"] as? [String: Any] {
        output["network"] = network
    }

    // Host
    if let host = jsonObject["host"] as? [String: Any] {
        output["host"] = host
    }

    return output
}

class StatusResponse {
    let successful: Bool
    let statusCode: Int?
    let data: Data?
    
    init(successful: Bool, statusCode: Int?, data: Data?) {
        self.successful = successful
        self.statusCode = statusCode
        self.data = data
    }
}
