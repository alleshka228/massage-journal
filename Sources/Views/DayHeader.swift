import SwiftUI

struct DayHeader: View {
    @ObservedObject var store: JournalStore

    var body: some View {
        HStack(spacing: 8) {
            arrow("chevron.left") {
                store.shift(by: -1)
            }

            Button {
                if !store.isToday { store.goToToday() }
            } label: {
                VStack(spacing: 2) {
                    Text(store.dayTitle)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(store.isToday ? "сегодня" : "вернуться к сегодня")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            arrow("chevron.right") {
                store.shift(by: 1)
            }
        }
        .padding(.vertical, 6)
    }

    private func arrow(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.05, green: 0.45, blue: 0.41))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white))
                .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
}
