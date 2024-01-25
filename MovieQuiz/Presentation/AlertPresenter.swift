//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 22.01.2024.
//
import UIKit

final class AlertPresenter {
    
    weak var delegate: MovieQuizPresenter?
    
    /// отображение алерта об ошибке загрузки данных из сети
    func networkError(alert model: AlertModel, on screen: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) {[weak self] _ in
            self?.delegate?.reloadData()
        }
        
        alert.addAction(action)
        screen.present(alert, animated: true, completion: nil)
    }
    
    /// отображение результата квиза и статистики по прошлым играм
    func gameResult(alert model: AlertModel, on screen: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) {[weak self] _ in
            self?.delegate?.restartGame()
        }
        
        alert.addAction(action)
        screen.present(alert, animated: true, completion: nil)
    }
}
