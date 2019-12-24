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
//    var trackId: Int
    var trackName: String?
    var collectionId: Int
    var collectionName: String
    var artworkUrl60: URL
    var releaseDate: String
}

struct ContentView: View {
    @State private var results = [Result]()
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
                }
                .pickerStyle(SegmentedPickerStyle())
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
                    .onTapGesture {
                        let keyWindow = UIApplication.shared.connectedScenes
                                           .filter({$0.activationState == .foregroundActive})
                                           .map({$0 as? UIWindowScene})
                                           .compactMap({$0})
                                           .first?.windows
                                           .filter({$0.isKeyWindow}).first
                        keyWindow!.endEditing(true)
                    }
                    Spacer()
                }
            }
            Section {
                List(results.prefix(12), id: \.collectionId) {
                    item in
                    HStack {
                        URLImage(item.artworkUrl60)
                        VStack(alignment: .leading){
                            if self.searchType == 0 {
                                Text(item.trackName ?? "")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Text(item.collectionName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(item.releaseDate)
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
