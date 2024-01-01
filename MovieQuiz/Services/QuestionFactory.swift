//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 10.12.2023.
//
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
  
  var delegate: QuestionFactoryDelegate?
  
  private let moviesLoader: MoviesLoadingProtocol
  private var movies: [MostPopularMovie] = []
  
  init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate?) {
    self.moviesLoader = moviesLoader
    self.delegate = delegate
  }
  
  func loadData() {
    moviesLoader.loadMovies { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch result {
        case .success(let mostPopularMovies):
          self.movies = mostPopularMovies.items
          self.delegate?.didLoadDataFromServer()
        case .failure(let error):
          self.delegate?.didFailToLoadData(with: error)
        }
      }
    }
  }
  
  func requestNextQuestion() {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      let index = (0..<self.movies.count).randomElement() ?? 0
      guard let movie = self.movies[safe: index] else { return }
      var imageData = Data()

      do {
        imageData = try Data(contentsOf: movie.imageURL)
      } catch {
        print("Failed to load image")
      }

      let rating = Float(movie.rating) ?? 0
      let randomRating = Int.random(in: Int(rating-1)...Int(min(rating+1, 9)))
      let randomCondition = Bool.random()
      let correctAnswer = randomCondition ? rating > Float(randomRating) : rating < Float(randomRating)
      let text = "Рейтинг этого фильма \(randomCondition ? "больше" : "меньше") чем \(randomRating)?"
      let question = QuizQuestion(image: imageData,
                                  text: text,
                                  correctAnswer: correctAnswer
      )
      DispatchQueue.main.async {[weak self] in
        guard let self = self else {
          return
        }
        self.delegate?.didReceiveNextQuestion(question: question)
      }
    }
  }
}
