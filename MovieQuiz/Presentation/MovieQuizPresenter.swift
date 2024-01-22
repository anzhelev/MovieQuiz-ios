//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 15.01.2024.
//
import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    // MARK: - Initializer
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        viewController.disableButtons()
        viewController.showLoadingIndicator()
        questionFactory?.loadData()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: message)
    }
    
    func showErrorAlert(with message: String) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.enableButtons()
        }
    }
    
    // MARK: - Functions
    // повторная загрузка данных при ошибке
    func reloadData() {
        viewController?.disableButtons()
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    //  проверяем, закончился ли квиз
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    //  увеличиваем счетчик правильных ответов если надо
    private func correctAnswersCount(increace: Bool) {
        if increace {
            correctAnswers += 1
        }
    }
    
    // рестарт квиза
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        viewController?.showLoadingIndicator()
    }
    
    // увеличиваем счетчик вопросов
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // конвертер для модели текущего вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // обработка нажатия кнопки ДА
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    // обработка нажатия кнопки НЕТ
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // определение правильности ответа
    private func didAnswer(isYes: Bool) {
        viewController?.disableButtons()
        if let currentQuestion = currentQuestion {
            proceedWithAnswer(isCorrect: isYes ? currentQuestion.correctAnswer : !currentQuestion.correctAnswer)
        }
    }
    
    // визуализация ответа для пользователя
    private func proceedWithAnswer(isCorrect: Bool) {
        correctAnswersCount(increace: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // обработка результатов квиза
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(game:
                                        GameRecord(
                                            correct: correctAnswers,
                                            total: questionsAmount,
                                            date: Date())
            )
            var text = correctAnswers == self.questionsAmount ?
            "Поздравляем, у вас 10 из 10!\n" :
            "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
            text.append(statisticService?.statistics ?? "")
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.showLoadingIndicator()
        }
    }
}
