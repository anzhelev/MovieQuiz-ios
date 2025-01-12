import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
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
    /// запуск отображения нового вопроса если все данные получены
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
    
    /// запускает генерацию нового вопроса если данные с сервера успешно загружены
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    /// алерт об ошибке с описанием
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: message)
    }
    
    /// алерт об ошибке с заданным сообщением
    func showErrorAlert(with message: String) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: message)
    }
    
    // MARK: - Public methods
    /// повторная загрузка данных при ошибке
    func reloadData() {
        viewController?.disableButtons()
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    /// рестарт квиза
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        viewController?.showLoadingIndicator()
    }
    
    /// конвертер для модели текущего вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    /// обработка нажатия кнопки ДА
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    /// обработка нажатия кнопки НЕТ
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - Private Methods
    /// проверяем, был ли вопрос последним
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    /// увеличиваем счетчик вопросов
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    ///  увеличиваем счетчик правильных ответов если надо
    private func correctAnswersCount(increace: Bool) {
        if increace {
            correctAnswers += 1
        }
    }
    
    /// определяем, был ли ответ на вопрос правильным
    private func didAnswer(isYes: Bool) {
        viewController?.disableButtons()
        if let currentQuestion = currentQuestion {
            proceedWithAnswer(isCorrect: isYes ? currentQuestion.correctAnswer : !currentQuestion.correctAnswer)
        }
    }
    
    /// меняем цвет рамки чтобы показать пользователю был ли ответ правильным
    private func proceedWithAnswer(isCorrect: Bool) {
        correctAnswersCount(increace: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    /// обрабатываем результат квиза, обновляем статистику и показываем пользователю итог
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
            
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз",
                completion:  {[weak self] _ in
                    self?.restartGame()
                })
            
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.showLoadingIndicator()
        }
    }
}
