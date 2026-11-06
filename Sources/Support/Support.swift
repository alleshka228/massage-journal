import Foundation
import UIKit

/// Форматирование денег в рублях.
enum Money {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = " "
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    /// "12 345 ₽"
    static func string(_ value: Double) -> String {
        plain(value) + " ₽"
    }

    /// "12 345"
    static func plain(_ value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

/// Скрыть клавиатуру (для кнопки «Готово» над цифровой клавиатурой).
func hideKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
