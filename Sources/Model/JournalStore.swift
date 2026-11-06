import Foundation
import Combine

/// Хранилище смены: записи по дням, итоги и зарплата.
final class JournalStore: ObservableObject {
    /// Ставка зарплаты — ровно 21% от выручки за день.
    static let salaryRate = 0.21

    @Published var day: Date = Calendar.current.startOfDay(for: Date())
    @Published var slots: [Slot] = [] {
        didSet {
            if isReady { saveCurrentDay() }
        }
    }

    private var days: [String: [Slot]] = [:]
    private let storeKey = "massage.journal.v1"
    private var isReady = false
    private let calendar = Calendar.current

    init() {
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let saved = try? JSONDecoder().decode([String: [Slot]].self, from: data) {
            days = saved
        }
        slots = days[key(for: day)] ?? Self.makeSlots()

        // Демо-данные для скриншотов из симулятора: приложение запускается с аргументом -demoData
        if ProcessInfo.processInfo.arguments.contains("-demoData") {
            slots = Self.demoSlots()
        }

        isReady = true
    }

    /// Пример заполненной смены — только для запуска с флагом -demoData.
    static func demoSlots() -> [Slot] {
        var slots = makeSlots()
        let demo: [(Int, String, MassageZone, String)] = [
            (0, "Иванова", .shvz, "2500"),
            (1, "Петров", .back, "3000"),
            (3, "Смирнова", .lowerBack, "2800"),
            (4, "Кузнецов", .neckChest, "2600"),
            (6, "Попова", .spine, "3200"),
            (7, "Соколов", .backAndLowerBack, "3500"),
            (16, "Морозова", .shvz, "2700"),
            (18, "Волков", .back, "3100"),
            (20, "Зайцева", .lowerBack, "2900"),
            (22, "Лебедев", .neckChest, "3300"),
            (27, "Орлов", .leg, "2400")
        ]
        for item in demo where item.0 < slots.count {
            slots[item.0].client = item.1
            slots[item.0].zone = item.2
            slots[item.0].price = item.3
        }
        return slots
    }

    // MARK: - Итоги

    var total: Double {
        slots.reduce(0) { $0 + $1.priceValue }
    }

    var salary: Double {
        (total * Self.salaryRate * 100).rounded() / 100
    }

    var filledCount: Int {
        slots.filter { $0.hasData }.count
    }

    // MARK: - Дни

    var isToday: Bool {
        calendar.isDateInToday(day)
    }

    var dayTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        // Шаблон, а не жёсткий dateFormat: иначе месяц выходит в именительном падеже («6 ноябрь»)
        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        let text = formatter.string(from: day)
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }

    func shift(by offset: Int) {
        guard let newDay = calendar.date(byAdding: .day, value: offset, to: day) else { return }
        day = calendar.startOfDay(for: newDay)
        slots = days[key(for: day)] ?? Self.makeSlots()
    }

    func goToToday() {
        go(to: Date())
    }

    /// Переход к произвольному дню из календаря.
    func go(to date: Date) {
        day = calendar.startOfDay(for: date)
        slots = days[key(for: day)] ?? Self.makeSlots()
    }

    // MARK: - Время ячеек

    func timeLabel(index: Int) -> String {
        Self.timeFormatter.string(from: ShiftConfig.date(forSlot: index, in: day))
    }

    func endLabel(index: Int) -> String {
        let start = ShiftConfig.date(forSlot: index, in: day)
        let end = start.addingTimeInterval(TimeInterval(ShiftConfig.slotMinutes * 60))
        return Self.timeFormatter.string(from: end)
    }

    // MARK: - Сохранение

    private func key(for date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    private func saveCurrentDay() {
        days[key(for: day)] = slots
        guard let data = try? JSONEncoder().encode(days) else { return }
        UserDefaults.standard.set(data, forKey: storeKey)
    }

    static func makeSlots() -> [Slot] {
        (0 ..< ShiftConfig.slotCount).map { Slot(id: $0) }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
