import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    
    @IBOutlet weak private var previewImage: UIImageView!
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties

    var gameOverAlert = AlertPresenter()
    private var networkErrorAlert = AlertPresenter()

    private let presenter = MovieQuizPresenter()
    
    // MARK: - Override Properties
    // меняем цвет StatusBar на белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // задаем свойства
        presenter.viewController = self
        presenter.questionFactory?.delegate = self
        gameOverAlert.delegate = self
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        presenter.statisticService = StatisticServiceImplementation()
        
        // применяем настройки шрифтов
        setupUI()
        
        // начинаем загрузку данных из сети
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    // действие при успешной загрузке данных из сети
    func didLoadDataFromServer() {
        hideLoadingIndicator() // скрываем индикатор загрузки
        presenter.questionFactory?.requestNextQuestion()
    }
    
    // действие при ошибке загрузки данных из сети
    func didFailToLoadData(with error: Error) {
        showNetworkErrorAlert(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresenterDelegate
    func startNewQuiz() {
        presenter.resetQuestionIndex()
//        correctAnswers = 0
        presenter.questionFactory?.requestNextQuestion()
    }
    
    // MARK: - IB Actions
    // обработка нажатия кнопки НЕТ
    @IBAction private func noButtonDidTapped(_ sender: Any) {
        presenter.noButtonDidTapped()
    }
    
    // обработка нажатия кнопки ДА
    @IBAction private func yesButtonDidTapped(_ sender: Any) {
        presenter.yesButtonDidTapped()
    }
    
    // MARK: - Private Methods
    // формат шрифтов текстовых полей и кнопок
    private func setupUI() {
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    
    // приватный метод вывода на экран нового вопроса
    func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        previewImage.layer.borderWidth = 0
    }
    
    // функция отображения реакции на ответ на вопрос и переход к следующему этапу
    func showAnswerResult(isCorrect: Bool) {
        // отключаем кнопки Да/Нет до показа следующего вопроса
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        // увеличиваем счетчик правильных ответов, если нужно
        if isCorrect {
            presenter.correctAnswersIncrement()
        }
        
        // рисуем рамку нужного цвета
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // многозначительная пауза перед показом следующего вопроса (или результата квиза)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            presenter.showNextQuestionOrResults()
        }
    }
        
    // функция отображения индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    // функция сокрытия индикатора загрузки
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    // отображаем алерт при ошибке сети
    private func showNetworkErrorAlert(message: String) {
        hideLoadingIndicator()
        let alert = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз"
        )
        networkErrorAlert.showResult(show: alert, where: self)
    }
}
