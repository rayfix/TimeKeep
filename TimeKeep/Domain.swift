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

extension Project {
  static var mock: Self {
    Self(id: .init(uuidString: "8f19e1f2-7022-11ee-a175-6f3b7445f7f6")!,
         name: "Study Swift",
         timeEvents: [
          .init(id: .init(uuidString: "99c9f98e-7022-11ee-bd6a-8fdd88bbadd2")!,
                date: .date(year: 2023, month: 9, day: 16)!,
                duration: .minutes(125)),
          .init(id: .init(uuidString: "99c9f98e-7022-11ee-bd6a-8fdd88bbadd3")!,
                date: .date(year: 2023, month: 9, day: 16)!,
                duration: .minutes(5))
         ])
  }
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
