import Foundation

///  структура записи результата игры для обновления статистики
struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    /// метод сравнения квизов по количеству верных ответов (если количество совпадает, тоже обновляем)
    func isBetterThan(_ another: GameRecord) -> Bool {
        correct >= another.correct
    }
}
