//
//  ContentView.swift
//  TimeKeep
//
//  Created by Ray Fix on 4/8/23.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationStack {
      ProjectsListView(store: .init(initialState: ProjectsListFeature.State(projects: [])) {
        ProjectsListFeature()
      })
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
