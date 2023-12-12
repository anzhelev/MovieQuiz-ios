//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 12.12.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {    // 1
    
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
