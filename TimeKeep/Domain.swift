//
//  Domain.swift
//  TimeKeep
//
//  Created by Ray Fix on 4/8/23.
//

import Foundation
import IdentifiedCollections
import Tagged

struct Time: Identifiable, Codable, Hashable {
  var id: Tagged<Time, UUID>
  var date: Date
  var duration: Duration
}

struct Project: Identifiable, Codable, Hashable {
  var id: Tagged<Project, UUID>
  var name: String
  var times: IdentifiedArrayOf<Time>
  
  enum Period {
    case all
    case day(Date)
  }
  
  func total(filter: Period = .all) -> Duration {
    let filtered: [Time]
    switch filter {
    case .all:
      filtered = Array(times)
    case let .day(filterDate):
      filtered = times.filter {
        Calendar.autoupdatingCurrent.isDate(filterDate, inSameDayAs: $0.date)
      }
    }
    return filtered.reduce(Duration.zero) { $0 + $1.duration }
  }  
}


