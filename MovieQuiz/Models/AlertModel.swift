import UIKit

/// модель для отображения результатов квиза или ошибок
struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    var completion: ((UIAlertAction) -> Void)? = nil
}
