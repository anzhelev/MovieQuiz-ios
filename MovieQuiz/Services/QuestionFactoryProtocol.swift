//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 11.12.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    
    var delegate: QuestionFactoryDelegate? { get set }
    
    
    
    func requestNextQuestion()
}
