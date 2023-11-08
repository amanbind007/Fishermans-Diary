//
//  AddNewFishView.swift
//  Fisherman's Keeper
//
//  Created by Aman Bind on 19/10/23.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct AddNewFishView: View {
    var fish: Fish
    
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel = AddNewFishViewModel()
    
    var isFormValid: Bool {
        if viewModel.hasCustomTitle {
            guard let customTitle = viewModel.customTitle, !customTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
                return false
            }
        }

        if viewModel.hasNote {
            guard let note = viewModel.note, !note.trimmingCharacters(in: .whitespaces).isEmpty else {
                return false
            }
        }

        return true
    }
    
    var body: some View {
        NavigationStack {
            Form(content: {
                Section {
                    HStack(alignment: .top) {
                        Text(fish.scientificName)
                            .frame(alignment: .leading)
                        Spacer()
                        
                        CachedAsyncImage(url: URL(string: fish.imageURL)) { image in
                            
                            image
                                .resizable()
                                .cornerRadius(10)
                                
                        } placeholder: {
                            Image("fishPlaceholder", bundle: Bundle(path: "Assets"))
                                .resizable()
                                .cornerRadius(10)
                        }
                        .frame(width: 120, height: 80)
                    }
                    
                } header: {
                    Text("Current Title")
                        .font(.caption)
                }
                
                Section {
                    HStack {
                        Text(fish.scientificName)
                            .font(Font.custom("PTSerif-BoldItalic", size: 20))
                    }
                    if let commonName = fish.commonEnglishName {
                        HStack {
                            Text(commonName)
                                .font(Font.custom("PTSerif-Regular", size: 17))
                        }
                    }
                    HStack {
                        Text(fish.familyName)
                            .font(Font.custom("PTSerif-Regular", size: 15))
                    }
                } header: {
                    Text("Scientific Name, Common English Name, Family Name")
                        .font(.caption)
                }

                Section {
                    HStack {
                        Toggle("Add Custom Title", isOn: $viewModel.hasCustomTitle)
                    }
                    
                    if viewModel.hasCustomTitle {
                        HStack {
                            TextField("Title", text: $viewModel.customTitle ?? "")
                                .lineLimit(3)
                                .textInputAutocapitalization(.sentences)
                                .autocorrectionDisabled()
                        }
                    }
                    
                    HStack {
                        Toggle("Add Note", isOn: $viewModel.hasNote)
                    }
                    if viewModel.hasNote {
                        HStack {
                            TextField("Enter Note", text: $viewModel.note ?? "", axis: .vertical)
                                .lineLimit(3)
                                .textInputAutocapitalization(.sentences)
                                .autocorrectionDisabled()
                        }
                    }
                    
                    HStack {
                        Toggle("Add Fish Count", isOn: $viewModel.hasFishCount)
                    }
                    
                    if viewModel.hasFishCount {
                        HStack {
                            Stepper("Fish Count: \(viewModel.fishCount)", value: $viewModel.fishCount, in: 0 ... Int.max)
                        }
                    }
                        
                } header: {
                    Text("Title and Note")
                        .font(.caption)
                }
                
            })
            .navigationTitle(fish.scientificName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    // this button should be only be enabled when the form is valid else it should be disabled
                    Button(action: {
                        viewModel.saveFish(fish: fish, context: context)
                        
                        dismiss()
                    }, label: {
                        Text("Save")
                        
                    })
                    .disabled(!isFormValid)
                }
            })
        }
    }
}

#Preview {
    NavigationStack {
        AddNewFishView(fish: FishPreviewProvider.fish)
    }
}
