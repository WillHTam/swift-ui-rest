//
//  ContentView.swift
//  applemusicfetch
//
//  Created by William on 12/19/19.
//  Copyright © 2019 William T. All rights reserved.
//

import SwiftUI
import URLImage

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
    var trackPrice: Double
    var artworkUrl30: URL
}

struct albumResponse: Codable {
    var albumResults: [albumResult]
}

struct albumResult: Codable {
    var collectionName: String
    var releaseDate: String
    var artworkUrl60: URL
}

struct ContentView: View {
    @State private var results = [Result]()
    @State private var albumResults = [albumResult]()
    @State private var searchTerm = ""
    @State private var searchType = 0
    let types = ["Song", "Album"]
    var disableForm: Bool {
        searchTerm == ""
    }
    
    var body: some View {
        Form{
            Section {
                ZStack{
                    TextField("Enter Term", text: $searchTerm)
                }
                .frame(height: 20)
            }
            Section (header: Text("Song or Album?")) {
                Picker("Search Type", selection: $searchType) {
                    ForEach(0 ..< types.count) {
                        Text(self.types[$0])
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            Section {
                HStack {
                    Spacer()
                    Button(action: {
                        self.loadData()
                    }){
                        Text("Search")
                    }
                    .disabled(disableForm)
                    .cornerRadius(10)
                    .frame(width:200, height: 40)
                    .font(.headline)
                    Spacer()
                }
            }
            Section {
                List(results.prefix(12), id: \.trackId) {
                    item in
                    HStack {
                        URLImage(item.artworkUrl30)
                        VStack(alignment: .leading){
                            Text(item.trackName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(item.collectionName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    func loadData() {
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchTerm.replacingOccurrences(of: " ", with: "+"))&entity=\(types[searchType].lowercased())") else {
            print("Invalid URL")
            return
        }

        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                    DispatchQueue.main.async {
                        // update our UI
                        self.results = decodedResponse.results
                    }
                    // everything is good, so we can exit
                    return
                }
            }
            // if we're still here it means there was a problem
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
