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
    
    @Published var moviesError: MovieStoreAPIError?
    
    private var cancellableSet: Set<AnyCancellable> = []
 /*
    //  Light
         
        init() {
            $indexEndpoint
                .flatMap { (indexEndpoint) -> AnyPublisher<[Movie], Never> in
                    self.movieAPI.fetchMoviesLight(from:
                                           Endpoint( index: indexEndpoint)!)}
                .assign(to: \.movies, on: self)
                .store(in: &self.cancellableSet)
        }
 */
/*
//  Without Errors
     
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
    
    //  With Errors
    init() {
        $indexEndpoint
            .setFailureType(to: MovieStoreAPIError.self)
            .flatMap { (indexEndpoint) -> AnyPublisher<[Movie], MovieStoreAPIError> in
                self.movieAPI.fetchMovies(from:  Endpoint( index: indexEndpoint)!)
                    .eraseToAnyPublisher()
        }
        .sink(receiveCompletion:  {[unowned self] (completion) in
            if case let .failure(error) = completion {
                self.moviesError = error
            }},
              receiveValue: { [unowned self] in self.movies = $0
        })
            .store(in: &self.cancellableSet)
    }
 
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
}
