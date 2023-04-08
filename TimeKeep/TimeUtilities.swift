//
//  TimeUtilities.swift
//  TimeKeep
//
//  Created by Ray Fix on 4/8/23.
//

import Foundation

var elapsed = Duration.seconds(100)

extension Duration {
  static func minutes(_ value: Double) -> Self {
    .seconds(value * 60)
  }
  static func minutes(_ value: some BinaryInteger) -> Self {
    .seconds(value * 60)
  }
  static func hours(_ value: some BinaryInteger) -> Self {
    .minutes(value * 60)
  }
  static func hours(_ value: Double) -> Self {
    .minutes(value * 60)
  }
}

extension Date {
  static func date(year: Int, month: Int, day: Int) -> Date? {
    let components = DateComponents(calendar: .autoupdatingCurrent, year: year, month: month, day: day)
    return components.date
  }
  
  var yearMonthDay: (year: Int, month: Int, day: Int) {
    let components = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: self)
    return (year: components.year!, month: components.month!, day: components.day!)
  }
}
