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

    enum Field: Hashable {
      case project(ProjectID)
    }
    
    @BindingState var focus: Field?
    var projectIDToEdit: ProjectID?
    @BindingState var projectName: String = ""
  }
  
  enum Action: Equatable, BindableAction {
    case addButtonTapped
    case binding(BindingAction<State>)
    case editProjectName(Project)
    case editProjectNameSubmit
  }
  
  @Dependency(\.uuid) var uuid
  
  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        let project = Project(id: .init(uuid()),
                              name: "Project",
                              timeEvents: [])
        state.projects.insert(project, at: 0)
        return .send(.editProjectName(project))
      case .binding:
        return .none
      case .editProjectName(let project):
        state.projectName = project.name
        state.projectIDToEdit = project.id
        state.focus = .project(project.id)
        return .none
      case .editProjectNameSubmit:
        state.focus = nil
        guard state.projectIDToEdit != nil else { return .none }
        state.projectIDToEdit = nil
        return .none
      }
    }
  }
}

struct ProjectsListView: View {
  let store: StoreOf<ProjectsListFeature>
  @FocusState var focus: ProjectsListFeature.State.Field?


  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Section {
          ForEach(viewStore.projects) { project in
            if viewStore.projectIDToEdit == project.id {
              TextField("", text: viewStore.$projectName)
                .focused($focus, equals: ProjectsListFeature.State.Field.project(project.id))
                .selectAllTextOnBeginEditing()
                .font(.headline)
                .onSubmit {
                  viewStore.send(.editProjectNameSubmit)
                }
            } else {
              Text(project.name).font(.headline)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            }
          }
        }
      }
      .bind(viewStore.$focus, to: $focus)
      .toolbar {
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
    })
  }
}
