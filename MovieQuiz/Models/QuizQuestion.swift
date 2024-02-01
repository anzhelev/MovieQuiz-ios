import Foundation

/// структура данных для массива вопросов
struct QuizQuestion {
    let image: Data // название фильма / картинки
    let text: String // вопрос по фильму
    let correctAnswer: Bool // правильный ответ на вопрос Да / Нет
}
