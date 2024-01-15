//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 15.01.2024.
//
import Foundation
import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // обработка нажатия кнопки НЕТ
    func noButtonDidTapped() {
        didAnswer(isYes: false)
    }
    
    // обработка нажатия кнопки ДА
    func yesButtonDidTapped() {
        didAnswer(isYes: true)
    }
    
    private func didAnswer(isYes: Bool) {
        if let currentQuestion = currentQuestion {
           viewController?.showAnswerResult(isCorrect: isYes ? currentQuestion.correctAnswer : !currentQuestion.correctAnswer)
        }
    }
    
    
    
    // конвертируем загруженные данные во вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let currentStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return currentStep
    }
    
    
    
    
}
