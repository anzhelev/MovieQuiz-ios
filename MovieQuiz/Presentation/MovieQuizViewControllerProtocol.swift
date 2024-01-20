//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 20.01.2024.
//
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func disableButtons()
    func showNetworkError(message: String)
}
