//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 13.12.2023.
//

import UIKit

final class AlertPresenter {
    
    weak var delegate: MovieQuizViewController?
    
    func showResult(show result: AlertModel, where screen: UIViewController) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) {[weak self] _ in
            self?.delegate?.startNewQuiz()
        }
        
        alert.addAction(action)
        screen.present(alert, animated: true, completion: nil)
    }
}
