//
//  MoviesViewModel.swift
//  CombineFetchAPI
//
//  Created by Tatiana Kornilova on 28/10/2019.
//

import Combine

final class MoviesViewModel: ObservableObject {
    var movieAPI = MovieStore.shared
    
    // input
    @Published var indexEndpoint: Int = 2
    // output
    @Published var movies = [Movie]()
    
    private var cancellableSet: Set<AnyCancellable> = []
/*
     
    // Without Error
    init() {
        $indexEndpoint
            .flatMap { (indexEndpoint) -> AnyPublisher<[Movie], Never> in
                self.movieAPI.fetchMovies(from:  Endpoint( index: indexEndpoint)!)
                    .replaceError(with: []) //TODO: Handle Errors
                    .eraseToAnyPublisher()
        }
            .assign(to: \.movies, on: self)
            .store(in: &self.cancellableSet)
    }
 */
     //  Light
            init() {
                $indexEndpoint
                    .flatMap { (indexEndpoint) -> AnyPublisher<[Movie], Never> in
                        self.movieAPI.fetchMoviesLight(from:
                                               Endpoint( index: indexEndpoint)!)}
                    .assign(to: \.movies, on: self)
                    .store(in: &self.cancellableSet)
            }
         
 
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
       }
}

