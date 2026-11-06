import SwiftUI

/// Панель итогов за день: выручка и зарплата 21%.
struct TotalsBar: View {
    @ObservedObject var store: JournalStore

    private let topColor = Color(red: 0.05, green: 0.35, blue: 0.32)
    private let bottomColor = Color(red: 0.06, green: 0.50, blue: 0.45)
    private let salaryColor = Color(red: 0.63, green: 1.0, blue: 0.84)

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label("\(store.filledCount) из \(ShiftConfig.slotCount) занято", systemImage: "person.2.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer(minLength: 8)
                Text("зарплата 21%")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Выручка за день")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(Money.string(store.total))
                        .font(.system(.title3, design: .rounded).weight(.heavy))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 1) {
                    Text("Твоя зарплата")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(Money.string(store.salary))
                        .font(.system(.title3, design: .rounded).weight(.heavy))
                        .foregroundStyle(salaryColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [topColor, bottomColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }
}
