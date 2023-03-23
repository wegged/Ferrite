//
//  PluginsView.swift
//  Ferrite
//
//  Created by Brian Dashore on 1/11/23.
//

import SwiftUI
import SwiftUIX

struct PluginsView: View {
    @EnvironmentObject var pluginManager: PluginManager
    @EnvironmentObject var navModel: NavigationViewModel

    @AppStorage("Behavior.AutocorrectSearch") var autocorrectSearch = true

    @State private var installedSourcesEmpty = false
    @State private var installedActionsEmpty = false
    @State private var checkedForPlugins = false

    @State private var isEditingSearch = false
    @State private var isSearching = false
    @State private var searchText: String = ""

    @State private var viewTask: Task<Void, Never>?

    var body: some View {
        NavView {
            ZStack {
                if checkedForPlugins {
                    switch navModel.pluginPickerSelection {
                    case .sources:
                        PluginAggregateView<Source, SourceJson>(
                            searchText: $searchText,
                            pluginsEmpty: $installedSourcesEmpty
                        )
                    case .actions:
                        PluginAggregateView<Action, ActionJson>(
                            searchText: $searchText,
                            pluginsEmpty: $installedActionsEmpty
                        )
                    }
                }
            }
            .overlay {
                if checkedForPlugins {
                    switch navModel.pluginPickerSelection {
                    case .sources:
                        if installedSourcesEmpty, pluginManager.availableSources.isEmpty {
                            EmptyInstructionView(title: "No Sources", message: "Add a plugin list in Settings")
                        }
                    case .actions:
                        if installedActionsEmpty, pluginManager.availableActions.isEmpty {
                            EmptyInstructionView(title: "No Actions", message: "Add a plugin list in Settings")
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .backport.onAppear {
                viewTask = Task {
                    await pluginManager.fetchPluginsFromUrl()
                    checkedForPlugins = true
                }
            }
            .onDisappear {
                viewTask?.cancel()
                checkedForPlugins = false
            }
            .navigationTitle("Plugins")
            .navigationSearchBar {
                SearchBar("Search", text: $searchText, isEditing: $isEditingSearch, onCommit: {
                    isSearching = true
                })
                .showsCancelButton(isEditingSearch || isSearching)
                .onCancel {
                    searchText = ""
                    isSearching = false
                }
            }
            .navigationSearchBarHiddenWhenScrolling(false)
            .customScopeBar {
                PluginPickerView()
                    .environmentObject(navModel)
            }
        }
    }
}

struct PluginsView_Previews: PreviewProvider {
    static var previews: some View {
        PluginsView()
    }
}
