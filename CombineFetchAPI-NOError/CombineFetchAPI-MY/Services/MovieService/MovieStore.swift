//
//  MovieRepository.swift
//  MovieKit
//
//  Created by Alfian Losari on 11/24/18.
//  Copyright © 2018 Alfian Losari. All rights reserved.
//

import Foundation
import Combine

public class MovieStore: MovieService {
    
    public static let shared = MovieStore()
    private init() {}
    private let apiKey = "1d9b898a212ea52e283351e521e17871" //"API_KEY"
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    func fetchMoviesLight(from endpoint: Endpoint)
           -> AnyPublisher<[Movie], Never> {
           return URLSession.shared.dataTaskPublisher(for: self.generateURL(with: endpoint)!)
            .map{$0.data}
            .decode(type: MoviesResponse.self, decoder: self.jsonDecoder)
            .replaceError(with: MoviesResponse (page: 1, totalResults: 1, totalPages: 2, results:[]))
            .map{$0.results}
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    func fetchMovies(from endpoint: Endpoint)
        -> Future<[Movie], MovieStoreAPIError> {
        return Future<[Movie], MovieStoreAPIError> {[unowned self] promise in
            guard let url = self.generateURL(with: endpoint) else {
                return promise(.failure(.urlError(URLError(URLError.unsupportedURL))))
            }
            
            self.urlSession.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode else {
                        throw MovieStoreAPIError.responseError(
                            (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }
                    return data
            }
            .decode(type: MoviesResponse.self, decoder: self.jsonDecoder)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { (completion) in
                if case let .failure(error) = completion {
                    switch error {
                    case let urlError as URLError:
                        promise(.failure(.urlError(urlError)))
                    case let decodingError as DecodingError:
                        promise(.failure(.decodingError(decodingError)))
                    case let apiError as MovieStoreAPIError:
                        promise(.failure(apiError))
                    default:
                        promise(.failure(.genericError))
                    }
                }
            }, receiveValue: { promise(.success($0.results)) })
            .store(in: &self.subscriptions)
        }
    }
    
    private func generateURL(with endpoint: Endpoint) -> URL? {
        guard var urlComponents = URLComponents(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)") else {
            return nil
        }
        
        let queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }

}

