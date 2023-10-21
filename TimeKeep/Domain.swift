//
//  Domain.swift
//  TimeKeep
//
//  Created by Ray Fix on 4/8/23.
//

import Dependencies
import Foundation
import IdentifiedCollections
import Tagged

struct TimeEvent: Identifiable, Codable, Hashable {
  var id: Tagged<Self, UUID>
  var date: Date
  var duration: Duration
}


struct Project: Identifiable, Codable, Hashable {
  var id: Tagged<Self, UUID>
  var name: String
  var timeEvents: IdentifiedArrayOf<TimeEvent>
}

protocol TimeEventFilter: Hashable {
  func isIncluded(_ date: Date) -> Bool
}

struct AllTimeEventFilter: TimeEventFilter, Hashable {
  func isIncluded(_ date: Date) -> Bool { true }
}
extension TimeEventFilter where Self == AllTimeEventFilter {
  static var all: Self { Self() }
}

struct ExactDayTimeEventFilter: TimeEventFilter, Hashable {
  let date: Date
  func isIncluded(_ input: Date) -> Bool {
    Calendar.autoupdatingCurrent.isDate(input, inSameDayAs: date)
  }
}
extension TimeEventFilter where Self == ExactDayTimeEventFilter {
  static func day(_ date: Date) -> Self {
    Self(date: date)
  }
}

extension Project {
  func total(filter: some TimeEventFilter = .all) -> Duration {
    let filtered: [TimeEvent] = timeEvents.filter { filter.isIncluded($0.date) }
    return filtered.reduce(Duration.zero) { $0 + $1.duration }
  }
}

final class ProjectTimer {
  private var accumulated: Duration = .zero
  private var startTime: Date?
  
  @Dependency(\.date.now) var now
  
  private var mark: Duration {
    guard let startTime else { return .zero }
    return .seconds(now.timeIntervalSince(startTime))
  }
  
  var isRunning: Bool { startTime != nil }
  
  func start() {
    guard !isRunning else { return }
    startTime = now
  }
  
  var elapsed: Duration {
    accumulated + mark
  }
  
  func stop() {
    guard isRunning else { return }
    accumulated += mark
    startTime = nil
  }
  
  func reset() {
    startTime = nil
    accumulated = .zero
  }
}
