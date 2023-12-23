import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - IB Outlets
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    
    @IBOutlet weak private var previewImage: UIImageView!
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Private Properties
    private let questionsAmount: Int = 10 // количество вопросов в квизе
    private var currentQuestionIndex = 0 // индекс текущего вопроса
    private var correctAnswers = 0 // счетчик правильных ответов
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var gameOverAlert = AlertPresenter()
    private var statisticService = StatisticServiceImplementation()
    
    // MARK: - Override Properties
    // меняем цвет StatusBar на белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory?.delegate = self
        gameOverAlert.delegate = self
        questionFactory?.requestNextQuestion()
//        statisticService.resetStatistics() // обнуляем статистику на старте приложения (для тестирования)
                
        // формат шрифтов текстовых полей и кнопок
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "SDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "SDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async {[weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    func startNewQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - IB Actions
    // обработка нажатия кнопки НЕТ
    @IBAction private func noButtonDidTapped(_ sender: Any) {
        if let currentQuestion = currentQuestion {
            showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        }
    }
    
    // обработка нажатия кнопки ДА
    @IBAction private func yesButtonDidTapped(_ sender: Any) {
        if let currentQuestion = currentQuestion {
            showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        }
    }
    
    // MARK: - Private Methods
    // конвертируем моковый вопрос во вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let currentStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return currentStep
    }
    
    // приватный метод вывода на экран нового вопроса
    private func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        previewImage.layer.borderWidth = 0
    }
    
    // функция отображения реакции на ответ на вопрос и переход к следующему этапу
    private func showAnswerResult(isCorrect: Bool) {
        // отключаем кнопки Да/Нет до показа следующего вопроса
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        // увеличиваем счетчик правильных ответов, если нужно
        if isCorrect {
            correctAnswers += 1
        }
        
        // рисуем рамку нужного цвета
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // многозначительная пауза перед показом следующего вопроса (или результата квиза)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        }
    }
    
    // функция перехода к следующему вопросу или к показу результатов квиза
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {// если вопрос был последним, покажем результаты
            // обновляем статистику раундов
            statisticService.update(game:
                                        GameRecord(
                                            correct: correctAnswers,
                                            total: questionsAmount,
                                            date: Date())
            )
            
            var text = correctAnswers == questionsAmount ?
            "Поздравляем, у вас 10 из 10!\n" :
            "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"

            text.append(statisticService.statistics)
            
            let alert = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз"
            )
            gameOverAlert.showResult(show: alert, where: self)
        } else {  // если остались еще вопросы, переходим к следующему
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
}
