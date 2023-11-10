//
//  MyFishListView.swift
//  Fisherman's Keeper
//
//  Created by Aman Bind on 07/10/23.
//

import AlertToast
import SwiftData
import SwiftUI

enum FilterOption {
    case keyword
    case title
    case note
    case familyName
    case scientificName
    case commonName
    case none
}

enum SortOption {
    case dateLowToHigh
    case dateHighToLow
    case AtoZ
    case ZtoA
}

struct MyFishListView: View {
    @Environment(\.modelContext) var context

    @Query var fishData: [FishData]
    
    @State var searchText: String = ""
    
    @State private var selectedFish: FishData?

    @State var isDeleted: Bool = false
    @State var isUpdated: Bool = false
    
    @State var selectedFilterOption: FilterOption = .keyword
    @State var selectedSortOption: SortOption = .dateHighToLow
    
    var filteredAndSortedFish: [FishData] {
            var filteredFish = fishData

            // Apply filter
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                switch selectedFilterOption {
                case .keyword:
                    filteredFish = fishData.filter { fish in
                        return fish.scientificName.lowercased().contains(searchText.lowercased()) ||
                            fish.commonName?.lowercased().contains(searchText.lowercased()) == true ||
                            fish.familyName.lowercased().contains(searchText.lowercased()) ||
                            fish.note?.lowercased().contains(searchText.lowercased()) == true ||
                            fish.title?.lowercased().contains(searchText.lowercased()) == true
                    }
                case .title:
                    filteredFish = fishData.filter { fish in
                        return fish.title?.lowercased().contains(searchText.lowercased()) == true
                    }
                case .note:
                    filteredFish = fishData.filter { fish in
                        return fish.note?.lowercased().contains(searchText.lowercased()) == true
                    }
                case .familyName:
                    filteredFish = fishData.filter { fish in
                        return fish.familyName.lowercased().contains(searchText.lowercased())
                    }
                case .scientificName:
                    filteredFish = fishData.filter { fish in
                        return fish.scientificName.lowercased().contains(searchText.lowercased())
                    }
                case .commonName:
                    filteredFish = fishData.filter { fish in
                        return fish.commonName?.lowercased().contains(searchText.lowercased()) == true
                    }
                case .none:
                    break
                }
            }

            // Apply sort
            switch selectedSortOption {
            case .dateLowToHigh:
                filteredFish.sort { $0.dateTime < $1.dateTime }
            case .dateHighToLow:
                filteredFish.sort { $0.dateTime > $1.dateTime }
            case .AtoZ:
                filteredFish.sort { $0.scientificName < $1.scientificName }
            case .ZtoA:
                filteredFish.sort { $0.scientificName > $1.scientificName }
            }

            return filteredFish
        }

    var body: some View {
        NavigationStack {
            List(selection: $selectedFish) {
                ForEach(filteredAndSortedFish, id: \.scientificName) { fish in

                    MyFishListItemView(fishData: fish, fishCount: fish.count, isUpdated: $isUpdated)
                        .onAppear(perform: {})
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                context.delete(fish)
                                isDeleted.toggle()
                                do {
                                    try context.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .toolbar(content: {
                ToolbarItem {
                    Menu("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                        Picker(selection: $selectedFilterOption) {
                            Text("Keyword")
                                .tag(FilterOption.keyword)
                            Text("Title")
                                .tag(FilterOption.title)
                            Text("Scientific Name")
                                .tag(FilterOption.scientificName)
                            Text("Family Name")
                                .tag(FilterOption.familyName)
                            Text("Common Name")
                                .tag(FilterOption.commonName)
                            Text("Notes")
                                .tag(FilterOption.note)
                            Text("None")
                                .tag(FilterOption.none)
                        } label: {
                            Text("Filter Options")
                        }
                    }
                }
                ToolbarItem {
                    Menu("Sort", systemImage: "arrow.up.and.down.text.horizontal") {
                        Picker(selection: $selectedSortOption) {
                            Text("Date - High to Low")
                                .tag(SortOption.dateHighToLow)
                            Text("Date - Low to High")
                                .tag(SortOption.dateLowToHigh)
                            Text("A to Z (Scientific Name)")
                                .tag(SortOption.AtoZ)
                            Text("Z to A (Scientific Name)")
                                .tag(SortOption.ZtoA)
                        } label: {
                            Text("Sort Options")
                        }
                    }
                }
            })

            .searchable(text: $searchText)
            .navigationTitle("My Fish List")
        }
        .toast(isPresenting: $isDeleted) {
            AlertToast(displayMode: .banner(.pop), type: .complete(.green), title: "Deleted Successfully")
        }
        .toast(isPresenting: $isUpdated) {
            AlertToast(displayMode: .banner(.pop), type: .complete(.green), title: "Updated Successfully")
        }
    }
}

#Preview {
    MyFishListView()
}
