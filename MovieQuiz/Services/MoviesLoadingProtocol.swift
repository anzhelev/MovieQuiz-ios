//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 01.01.2024.
//
protocol MoviesLoadingProtocol {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
