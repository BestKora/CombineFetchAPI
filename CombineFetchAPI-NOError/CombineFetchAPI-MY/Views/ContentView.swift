//
//  MoviesView.swift
//  CombineFetchAPI-MY
//
//  Created by Tatiana Kornilova on 11/11/2019.
//  Copyright © 2019 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct ContentView: View {
    @EnvironmentObject var moviesViewModel : MoviesViewModel
       
       var body: some View {
           VStack {
               Text("\(moviesViewModel.indexEndpoint)")
               Stepper("Enter your index", value: $moviesViewModel.indexEndpoint, in: 0...3)
                .padding()
               Picker("", selection: $moviesViewModel.indexEndpoint){
                   Text("\(Endpoint(index: 0)!.description)").tag(0)
                   Text("\(Endpoint(index: 1)!.description)").tag(1)
                   Text("\(Endpoint(index: 2)!.description)").tag(2)
                   Text("\(Endpoint(index: 3)!.description)").tag(3)
               }
               .pickerStyle(SegmentedPickerStyle())
               MoviesList(movies: moviesViewModel.movies)
           } // VStack
       } // body
}

struct MoviesList: View {
    var movies: [Movie]
    var body: some View {
        List{
            ForEach(movies) { movie in
                HStack {
                    MoviePosterImage(imageLoader: ImageLoaderCache.shared.loaderFor(path: movie.posterPath,size: .medium),posterSize: .medium)
                    VStack{
                        Text("\(movie.title)").font(.title)
                        Text("\( movie.overview)")
                            .lineLimit(3)
                        HStack {
                            PopularityBadge(score: Int(movie.voteAverage * 10))
                            Text(formatter.string(from: movie.releaseDate))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        } //HStack
                    } //VStack
                } // HStack
            } // foreach
        } // list
    } // body
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(MoviesViewModel())
    }
}
