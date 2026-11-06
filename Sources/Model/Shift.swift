import Foundation

/// Зоны массажа для выпадающего списка.
enum MassageZone: String, CaseIterable, Codable, Identifiable {
    case shvz = "ШВЗ"
    case back = "СПИНА"
    case lowerBack = "ПОЯСНИЦА"
    case spine = "ПОЗВОНОЧНИК"
    case neckChest = "ШЕЙНО-ГРУДНОЙ"
    case backAndLowerBack = "СПИНА+ПОЯСНИЦА"
    case arm = "РУКА"
    case leg = "НОГА"
    case lowerBackAndLeg = "ПОЯСНИЦА+НОГА"

    var id: String { rawValue }
}

/// Параметры смены. Меняя границы, можно получить другое число ячеек.
enum ShiftConfig {
    static let startHour = 8
    static let startMinute = 0

    static let endHour = 22
    static let endMinute = 0

    static let slotMinutes = 30

    static var startTotalMinutes: Int { startHour * 60 + startMinute }
    static var endTotalMinutes: Int { endHour * 60 + endMinute }

    /// 08:00–22:00 с шагом 30 минут = 28 ячеек.
    static var slotCount: Int {
        max(1, (endTotalMinutes - startTotalMinutes) / slotMinutes)
    }

    static var shiftTitle: String {
        String(format: "%02d:%02d–%02d:%02d", startHour, startMinute, endHour, endMinute)
    }

    static func startDate(for day: Date) -> Date {
        Calendar.current.date(bySettingHour: startHour, minute: startMinute, second: 0, of: day) ?? day
    }

    static func date(forSlot index: Int, in day: Date) -> Date {
        startDate(for: day).addingTimeInterval(TimeInterval(index * slotMinutes * 60))
    }
}

/// Одна ячейка сетки: фамилия, зона, стоимость.
struct Slot: Identifiable, Codable, Equatable {
    let id: Int
    var client: String = ""
    var zone: MassageZone?
    var price: String = ""

    var priceValue: Double {
        let cleaned = price
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(cleaned) ?? 0
    }

    var hasData: Bool {
        !client.trimmingCharacters(in: .whitespaces).isEmpty || zone != nil || priceValue > 0
    }
}
