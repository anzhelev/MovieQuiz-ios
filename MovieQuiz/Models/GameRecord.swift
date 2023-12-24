//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 22.12.2023.
//
import Foundation

struct GameRecord: Codable {
  let correct: Int
  let total: Int
  let date: Date
  
  // метод сравнения по количеству верных ответов (если количество совпадает, тоже обновляем)
  func isBetterThan(_ another: GameRecord) -> Bool {
    correct >= another.correct
  }
}
