//
//  LibraryView.swift
//  Ferrite
//
//  Created by Brian Dashore on 9/2/22.
//

import SwiftUI
import SwiftUIX

struct LibraryView: View {
    @EnvironmentObject var debridManager: DebridManager
    @EnvironmentObject var navModel: NavigationViewModel

    @State private var bookmarksEmpty = false
    @State private var historyEmpty = false

    @AppStorage("Behavior.AutocorrectSearch") var autocorrectSearch = true

    @State private var editMode: EditMode = .inactive

    @State private var searchText: String = ""
    @State private var isEditingSearch = false
    @State private var isSearching = false

    var body: some View {
        NavView {
            ZStack {
                switch navModel.libraryPickerSelection {
                case .bookmarks:
                    BookmarksView(searchText: $searchText, bookmarksEmpty: $bookmarksEmpty)
                case .history:
                    HistoryView(searchText: $searchText, historyEmpty: $historyEmpty)
                case .debridCloud:
                    DebridCloudView(searchText: $searchText)
                }
            }
            .overlay {
                switch navModel.libraryPickerSelection {
                case .bookmarks:
                    if bookmarksEmpty {
                        EmptyInstructionView(title: "No Bookmarks", message: "Add a bookmark from search results")
                    }
                case .history:
                    if historyEmpty {
                        EmptyInstructionView(title: "No History", message: "Start watching to build history")
                    }
                case .debridCloud:
                    if debridManager.selectedDebridType == nil {
                        EmptyInstructionView(title: "Cloud Unavailable", message: "Listing is not available for this service")
                    }
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: Application.shared.osVersion.majorVersion > 14 ? 10 : 18) {
                        Spacer()
                        EditButton()

                        switch navModel.libraryPickerSelection {
                        case .bookmarks, .debridCloud:
                            DebridPickerView {
                                Text(debridManager.selectedDebridType?.toString(abbreviated: true) ?? "Debrid")
                            }
                            .transaction {
                                $0.animation = .none
                            }
                        case .history:
                            HistoryActionsView()
                        }
                    }
                }
            }
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
                LibraryPickerView()
                    .environmentObject(debridManager)
                    .environmentObject(navModel)
            }
            .environment(\.editMode, $editMode)
        }
        .onChange(of: navModel.libraryPickerSelection) { _ in
            editMode = .inactive
        }
        .onDisappear {
            editMode = .inactive
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
