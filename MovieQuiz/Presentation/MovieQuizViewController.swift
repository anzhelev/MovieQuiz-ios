import UIKit

final class MovieQuizViewController: UIViewController {
    
    // меняем цвет StatusBar на белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - IB Outlets
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    
    @IBOutlet weak private var previewImage: UIImageView!
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0 // индекс текущего вопроса
    private var correctAnswers = 0 // счетчик правильных ответов
    
    // вью модель для состояния "Вопрос показан"
    private struct QuizStepViewModel {
        let image: UIImage // картинка с афишей фильма с типом UIImage
        let question: String // вопрос о рейтинге квиза
        let questionNumber: String // строка с порядковым номером текущего вопроса
    }
    
    // структура данных для массива вопросов
    private struct QuizQuestion {
        let image: String // название фильма / картинки
        let text: String // вопрос по фильму
        let correctAnswer: Bool // правильный ответ на вопрос Да / Нет
    }
    
    // массив вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    // массив вопросов в рандомном порядке
    private var randomQuestions: [QuizQuestion] = []
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // формат шрифтов текстовых полей и кнопок
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "SDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "SDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        
        // запускаем первый раунд квиза
        startNewQuiz()
    }
    
    // MARK: - IB Actions
    // обработка нажатия кнопки НЕТ
    @IBAction private func noButtonDidTapped(_ sender: Any) {
        if !randomQuestions[currentQuestionIndex].correctAnswer {
            correctAnswers += 1
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    // обработка нажатия кнопки ДА
    @IBAction private func yesButtonDidTapped(_ sender: Any) {
        if randomQuestions[currentQuestionIndex].correctAnswer {
            correctAnswers += 1
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    // MARK: - Private Methods
    // конвертируем моковый вопрос во вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let currentStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(randomQuestions.count)")
        return currentStep
    }
    
    // метод вывода на экран текущего вопроса
    private func show(quiz step: QuizStepViewModel) {
        // включаем кнопки Да/Нет
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        indexLabel.text = step.questionNumber
        previewImage.layer.borderWidth = 0
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    // функция заполнения массива вопросов в рандомном порядке
    private func questionsRandomizer() {
        randomQuestions = questions.shuffled()
    }
    
    // функция отображения реакции на ответ на вопрос и переход к следующему этапу
    private func showAnswerResult(isCorrect: Bool) {
        // отключаем кнопки Да/Нет до показа следующего вопроса
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        // рисуем рамку нужного цвета
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {// многозначительная пауза перед показом следующего вопроса (или результата квиза)
            self.showNextQuestionOrResults()
        }
    }
    
    // функция перехода к следующему вопросу или к показу результатов квиза
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == randomQuestions.count - 1 { // если вопрос был последним, покажем результаты
            quizResult()
        } else {// если остались еще вопросы, переходим к следующему
            currentQuestionIndex += 1
            let nextQuestion = convert(model: randomQuestions[currentQuestionIndex])
            show(quiz: nextQuestion)
        }
    }
    
    // функция отображения результатов квиза
    private func quizResult() {
        // создаём всплывающее окно с кнопкой
        let alert = UIAlertController(title: "Раунд окончен!",
                                      message: "Ваш результат: \(correctAnswers)/\(randomQuestions.count)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Сыграть еще раз", style: .default, handler: { _ in
            self.startNewQuiz()
        }))
        
        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }
    
    // функция запуска нового раунда квиза
    private func startNewQuiz() {
        questionsRandomizer()
        currentQuestionIndex = 0
        correctAnswers = 0
        let firstQuestion = convert(model: randomQuestions[currentQuestionIndex])
        show(quiz: firstQuestion)
    }
}
