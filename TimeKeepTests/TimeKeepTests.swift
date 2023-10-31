//
//  TimeKeepTests.swift
//  TimeKeepTests
//
//  Created by Ray Fix on 4/22/23.
//

import ComposableArchitecture
import Dependencies
import XCTest

@testable import TimeKeep

final class TimeKeepTests: XCTestCase {

  var dateValue: Date = .now
  
  func testProjectTimer() {
    let generator = DateGenerator { self.dateValue }
    
    let timer = withDependencies {
      $0.date = generator
    } operation: {
      return ProjectTimer()
    }
    
    XCTAssertFalse(timer.isRunning)
    
    timer.start()
    XCTAssert(timer.isRunning)
        
    timer.stop()
    XCTAssertFalse(timer.isRunning)
    
    dateValue += 1
    
    XCTAssertEqual(timer.elapsed, .zero)
    
    timer.start()
    dateValue += 1
    XCTAssertEqual(timer.elapsed, .seconds(1))
    
    dateValue += 3
    XCTAssertEqual(timer.elapsed, .seconds(4))
    
    // A stopped timer should not record elapsed time.
    timer.stop()
    dateValue += 400
    XCTAssertEqual(timer.elapsed, .seconds(4))
  }
  
  @MainActor
  func testAddProject() async {
    let store = TestStore(initialState: ProjectsListFeature.State(projects: [])) {
      ProjectsListFeature()
    } withDependencies: { values in
      values.uuid = .incrementing
    }
    
    let project = Project(id: .init(UUID(0)), name: "Project",
                          timeEvents: [])
    
    await store.send(.addButtonTapped) { state in
      state.projects = [project]
    }
    
    await store.receive(.editProjectName(project)) { state in
      state.focus = .project(project.id)
      state.projectName = "Project"
    }
    
    store.assert { state in
      XCTAssert(state.isAddDisabled)
    }
    
    await store.send(.set(\.$projectName, "Study Swift")) { state in
      state.projectName = "Study Swift"
    }
    
    await store.send(.editProjectNameSubmit) { state in
      state.focus = nil
      state.projects = [Project(id: .init(UUID(0)), name: "Study Swift", timeEvents: [])]
      state.projectName = ""
    }
    
    store.assert { state in
      XCTAssertFalse(state.isAddDisabled)
    }    
  }
}


