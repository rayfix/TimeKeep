//
//  ProjectsListFeature.swift
//  TimeKeep
//
//  Created by Ray Fix on 9/30/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectsListFeature: Reducer {

  struct State: Equatable {
    var projects: IdentifiedArrayOf<Project>
  }
  
  enum Action: Equatable {
    case addButtonTapped
  }
  
  @Dependency(\.uuid) var uuid
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        state.projects.insert(Project(id: .init(uuid()),
                                      name: "Project",
                                      timeEvents: []), at: 0)
        return .none
      }
    }
  }
}

struct ProjectsListView: View {
  let store: StoreOf<ProjectsListFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Section {
          ForEach(viewStore.state.projects) { project in
            Text(project.name)
          }
        }
      }.toolbar {
        Button {
          viewStore.send(.addButtonTapped, animation: .default)
        } label: {
          Image(systemName: "plus")
            .accessibilityLabel("Add note")
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    ProjectsListView(store: .init(initialState:
                                    ProjectsListFeature.State(projects: [])) {
      ProjectsListFeature()
        ._printChanges()
    })
  }
}
