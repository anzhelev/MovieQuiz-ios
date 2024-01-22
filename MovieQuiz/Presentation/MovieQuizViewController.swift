import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    
    @IBOutlet weak private var previewImage: UIImageView!
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Override Properties
    override var preferredStatusBarStyle: UIStatusBarStyle { // меняем цвет StatusBar на белый
        return .lightContent
    }
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private var showAlert = AlertPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // свойства
        presenter = MovieQuizPresenter(viewController: self)
        showAlert.delegate = presenter
        
        // настройки шрифтов
        setupUI()
    }
    
    // MARK: - Actions
    // обработка нажатия кнопки ДА
    @IBAction private func yesButtonDidTapped(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    // обработка нажатия кнопки НЕТ
    @IBAction private func noButtonDidTapped(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Functions
    // вывод на экран нового вопроса
    func show(quiz step: QuizStepViewModel) {
        previewImage.layer.borderColor = UIColor.clear.cgColor
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    // вывод результата квиза в алерте
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(title: result.title,
                               text: result.text,
                               buttonText: "Попробовать ещё раз"
        )
        
        showAlert.gameResult(alert: model, on: self)
    }
    
    // рисуем рамку постера нужного цвета в зависимости от ответа
    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // показать индикатор загрузки
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    // скрыть индикатор загрузки
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // отключить кнопки
    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    // включить кнопки
    func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // показать алерт ошибки сети
    func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка",
                               text: message,
                               buttonText: "Попробовать ещё раз"
        )
        
        showAlert.networkError(alert: model, on: self)
    }
    
    // формат шрифтов текстовых полей и кнопок
    private func setupUI() {
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
}
