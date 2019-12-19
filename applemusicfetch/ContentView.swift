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

struct ContentView: View {
    @State var results = [Result]()
    @State var searchTerm = ""
    var disableForm: Bool {
        searchTerm == ""
    }
    
    var body: some View {
        Form{
            Section {
                ZStack{
                    TextField("Text Here", text: $searchTerm)
                }
                .frame(height: 20)
            }
            Section {
                Button(action: {
                    self.loadData()
                }){
                    Text("Search")
                }
                .disabled(disableForm)
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
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchTerm.replacingOccurrences(of: " ", with: "+"))&entity=song") else {
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
