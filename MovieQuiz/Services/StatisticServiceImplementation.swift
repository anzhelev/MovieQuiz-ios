//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 22.12.2023.
//
import Foundation

final class StatisticServiceImplementation: StatisticService {
    
    // MARK: - Properties    
    // добавляем ключи и константу для удобства работы с UserDefaults
    private enum Keys: String {case totalCorrectAnswers, totalQuestionAmount, bestGame, gamesCount}
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double { // вычисляем общий процент правильных ответов
        get {
            let totalAmount = userDefaults.integer(forKey: Keys.totalQuestionAmount.rawValue)
            let correctAnswers = userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue)
            if totalAmount == 0 {
                return 0
            } else {
                return Double(correctAnswers) / Double(totalAmount) * 100
            }
        }
    }
    
    var gamesCount: Int { // счетчик завершенных раундов
        get {
            let count = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return count
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {// данные о лучшем сыгранном раунде
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var statistics: String { // генерируем текст с данными статистики для алерта
        get {
            var text = ""
            let game = bestGame
            text.append("Количество сыгранных квизов: \(gamesCount)\n")
            text.append("Рекорд: \(game.correct)/\(game.total) (\(dateToString(from: game.date)))\n")
            text.append("Средняя точность: \(String(format: "%.2f", totalAccuracy))%")
            return text
        }
    }
    
    // MARK: - Methods
    // обновляем данные статистики после завершения раунда
    func update(game score: GameRecord) {
        gamesCount += 1
        let totalAmount = userDefaults.integer(forKey: Keys.totalQuestionAmount.rawValue)
        let correctAnswers = userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        
        userDefaults.set(score.correct + correctAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        userDefaults.set(score.total + totalAmount, forKey: Keys.totalQuestionAmount.rawValue)
        
        if score.isBetterThan(bestGame) {
            bestGame = score
        }
    }
    
    //  функция форматирования даты в строку
    private func dateToString(from date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.YY HH:mm"
        return df.string(from: date)
    }
    
    //    func resetStatistics() { // сброс статистики
    //        userDefaults.set(nil, forKey: Keys.totalCorrectAnswers.rawValue)
    //        userDefaults.set(nil, forKey: Keys.totalQuestionAmount.rawValue)
    //        userDefaults.set(nil, forKey: Keys.gamesCount.rawValue)
    //        userDefaults.set(nil, forKey: Keys.bestGame.rawValue)
    //    }
}
