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
    private var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    var statisticService: StatisticService?
    var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func correctAnswersIncrement() {
        correctAnswers += 1
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
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async {[weak self] in
            self?.viewController?.show(quiz: viewModel)
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
    
    // функция перехода к следующему вопросу или к показу результатов квиза
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {// если вопрос был последним, покажем результаты
            // обновляем статистику раундов
            statisticService?.store(game:
                                        GameRecord(
                                            correct: correctAnswers,
                                            total: questionsAmount,
                                            date: Date())
            )
            
            var text = correctAnswers == questionsAmount ?
            "Поздравляем, у вас 10 из 10!\n" :
            "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
            
            text.append(statisticService?.statistics ?? "")
            
            let alert = AlertModel(title: "Этот раунд окончен!",
                                   message: text,
                                   buttonText: "Сыграть ещё раз"
            )
            if let viewController {
                viewController.gameOverAlert.showResult(show: alert, where: viewController)
            }
            
        } else {  // если остались еще вопросы, переходим к следующему
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    
}
