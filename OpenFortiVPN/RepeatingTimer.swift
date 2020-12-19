//
//  RepeatingTimer.swift
//  OpenFortiVPN
//
//  Created by Manuel Claveras on 18/12/2020.
//

import Foundation

class RepeatingTimer {

    let intervalInSeconds: TimeInterval
    let queue: DispatchQueue
    var eventHandler: (() -> Void)?
    private enum State {
        case suspended
        case active
    }
    private var state: State = .suspended
    
    init(timeInterval: TimeInterval) {
        self.intervalInSeconds = timeInterval
        self.queue = DispatchQueue(label: "openfortivpn.queue")
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + self.intervalInSeconds, repeating: self.intervalInSeconds)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    func resume() {
        guard state == .suspended else {
            return
        }
        state = .active
        timer.activate()
    }

    func suspend() {
        guard state == .active else {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        resume()
        eventHandler = nil
    }
}
