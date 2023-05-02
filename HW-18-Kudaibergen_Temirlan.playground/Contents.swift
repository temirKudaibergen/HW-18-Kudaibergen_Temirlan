import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: Initial Data

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    public let chipType: ChipType

    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }

        return Chip(chipType: chipType)
    }

    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

// MARK: Properties

private var mutex = NSCondition()
private var isLock = true
public var chipStorage: [Chip] = []

//MARK: Object
final class GeneratingQueue: Thread {
    private var runCount = 0
    
    func createNewInstance() {
        var timer = Timer.scheduledTimer(withTimeInterval: 2,
                                         repeats: true) { timer in
            mutex.lock()
            isLock = true
            chipStorage.append(Chip.make())
            self.runCount += 1
            if self.runCount == 5 {
                timer.invalidate()
            }
            do {
                mutex.signal()
                mutex.unlock()
            }
        }
    }
}
    
final class WorkerQueue: Thread {
    func solderChip() {
        mutex.lock()
        while !isLock {
            mutex.wait()
        }
        isLock = true
        mutex.unlock()
        Chip.sodering(chipStorage.last ?? Chip(chipType: .small))
    }
}

//MARK: Instances

let generat = GeneratingQueue()
let work = WorkerQueue()
generat.createNewInstance()
work.solderChip()
