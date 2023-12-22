//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 22.12.2023.
//

protocol StatisticService {
    func update(game score: GameRecord)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}