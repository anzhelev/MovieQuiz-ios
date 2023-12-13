import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
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
    
    private let questionsAmount: Int = 10
//    private let questionFactory = QuestionFactory()
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()
    private var currentQuestion: QuizQuestion?

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        
 
        
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
    
    // MARK: - IB Actions
    // обработка нажатия кнопки НЕТ
    @IBAction private func noButtonDidTapped(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        if !currentQuestion.correctAnswer {
            correctAnswers += 1
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    // обработка нажатия кнопки ДА
    @IBAction private func yesButtonDidTapped(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        
        
        if currentQuestion.correctAnswer {
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return currentStep
    }
   
    
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        previewImage.layer.borderWidth = 0
    }
   
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        // включаем кнопки Да/Нет

        
  
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
            
        }

//        alert.addAction(UIAlertAction(title: "Сыграть еще раз", style: .default, handler: {[weak self] _ in // слабая ссылка на self
//            guard let self = self else { return } // разворачиваем слабую ссылку
//            
//            
//        }))
        
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)

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
        
        // многозначительная пауза перед показом следующего вопроса (или результата квиза)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        }
    }
    
    // функция перехода к следующему вопросу или к показу результатов квиза
    private func showNextQuestionOrResults() {
//        if currentQuestionIndex == questionsAmount - 1 { // если вопрос был последним, покажем результаты
//            quizResult()
            
            if currentQuestionIndex == questionsAmount - 1 {
                let text = correctAnswers == questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
                
                let viewModel = QuizResultsViewModel( // 2
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                show(quiz: viewModel) // 3
                
            } else {// если остались еще вопросы, переходим к следующему
                currentQuestionIndex += 1
                self.questionFactory?.requestNextQuestion()
            }
        }
        
        //    // функция отображения результатов квиза
        //    private func quizResult() {
        //        // создаём всплывающее окно с кнопкой
        //        let alert = UIAlertController(title: "Раунд окончен!",
        //                                      message: "Ваш результат: \(correctAnswers)/\(questions.count)",
        //                                      preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "Сыграть еще раз", style: .default, handler: {[weak self] _ in // слабая ссылка на self
        //            guard let self = self else { return } // разворачиваем слабую ссылку
        //            self.startNewQuiz()
        //        }))
        //
        //        // показываем всплывающее окно
        //        self.present(alert, animated: true, completion: nil)
        //    }
        
        // функция запуска нового раунда квиза
        //    private func startNewQuiz() {
        ////        questionsRandomizer()
        //        currentQuestionIndex = 0
        //        correctAnswers = 0
        //        let firstQuestion = convert(model: questions[currentQuestionIndex])
        //        show(quiz: firstQuestion)
        //    }
        
    }
