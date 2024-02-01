import UIKit

final class AlertPresenter {
    func showAlert(alert model: AlertModel, on screen: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        alert.addAction(action)
        screen.present(alert, animated: true, completion: nil)
    }
}
