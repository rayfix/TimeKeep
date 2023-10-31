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
      case project(Project.ID)
    }
    
    @BindingState var focus: Field?
    @BindingState var projectName: String = ""
    
    // Computed state
    var editProjectNameID: Project.ID? {
      CasePath(Field.project).extract(from: focus)
    }
    
    var isAddDisabled: Bool {
      focus != nil
    }
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
        state.focus = .project(project.id)
        return .none
      case .editProjectNameSubmit:
        guard let id = state.editProjectNameID,
         var project = state.projects[id: id] else { return .none }
        project.name = state.projectName
        state.projects[id: id] = project
        state.focus = nil
        state.projectName = ""
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
            if viewStore.editProjectNameID == project.id {
              TextField("", text: viewStore.$projectName)
                .focused($focus, equals: ProjectsListFeature.State.Field.project(project.id))
                .selectAllTextOnBeginEditing()
                .onSubmit {
                  viewStore.send(.editProjectNameSubmit)
                }
            } else {
              HStack {
                Text(project.name)
                  .onTapGesture {
                    viewStore.send(.editProjectName(project))
                  }
                Spacer()
                Text(project.total().formatted())
              }
            }
          }
          .font(.headline)
        }
      }
      .bind(viewStore.$focus, to: $focus)
      .toolbar {
        Button {
          viewStore.send(.addButtonTapped, animation: .default)
        } label: {
          Image(systemName: "plus")
            .accessibilityLabel("Add project")
        }.disabled(viewStore.isAddDisabled)
      }
    }
  }
}

#Preview {
  NavigationStack {
    ProjectsListView(store: 
        .init(initialState:ProjectsListFeature.State(projects: [.mock])) {
      ProjectsListFeature()
    })
  }
}
