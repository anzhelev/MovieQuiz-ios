//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 12.12.2023.
//
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
    func showErrorAlert(with message: String) // уведомление об ошибке при загрузке данных
}
