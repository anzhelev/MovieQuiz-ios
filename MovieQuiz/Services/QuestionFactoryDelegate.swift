//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 12.12.2023.
//

protocol QuestionFactoryDelegate: AnyObject {    
    func didReceiveNextQuestion(question: QuizQuestion?) 
}
