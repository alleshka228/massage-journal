import SwiftUI

/// Календарь для быстрого перехода к любому дню смены.
struct CalendarSheet: View {
    @ObservedObject var store: JournalStore
    @Environment(\.dismiss) private var dismiss

    @State private var selection: Date

    private let accent = Color(red: 0.05, green: 0.45, blue: 0.41)

    init(store: JournalStore) {
        self.store = store
        _selection = State(initialValue: store.day)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                DatePicker(
                    "День смены",
                    selection: $selection,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(accent)

                Button {
                    store.go(to: selection)
                    Haptics.tap()
                    dismiss()
                } label: {
                    Text("Открыть этот день")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(accent)
                        )
                }
                .padding(.horizontal, 20)

                Button {
                    store.go(to: Date())
                    dismiss()
                } label: {
                    Text("Сегодня")
                        .font(.subheadline.weight(.semibold))
                }

                Spacer(minLength: 0)
            }
            .padding(.top, 6)
            .navigationTitle("Выбор дня")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}
