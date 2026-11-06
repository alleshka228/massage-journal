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
        isReady = true
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
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: day).capitalized
    }

    func shift(by offset: Int) {
        guard let newDay = calendar.date(byAdding: .day, value: offset, to: day) else { return }
        day = calendar.startOfDay(for: newDay)
        slots = days[key(for: day)] ?? Self.makeSlots()
    }

    func goToToday() {
        day = calendar.startOfDay(for: Date())
        slots = days[key(for: day)] ?? Self.makeSlots()
    }

    /// Сброс текущего дня перед новой сменой.
    func clearDay() {
        slots = Self.makeSlots()
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
