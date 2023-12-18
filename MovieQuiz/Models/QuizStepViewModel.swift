//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 10.12.2023.
//

import UIKit

// вью модель для состояния "Вопрос показан"
 struct QuizStepViewModel {
    let image: UIImage // картинка с афишей фильма с типом UIImage
    let question: String // вопрос о рейтинге квиза
    let questionNumber: String // строка с порядковым номером текущего вопроса
}
