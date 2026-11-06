import SwiftUI

struct ContentView: View {
    @StateObject private var store = JournalStore()
    @State private var showsClearConfirm = false

    private let accent = Color(red: 0.05, green: 0.45, blue: 0.41)
    private let background = Color(red: 0.95, green: 0.96, blue: 0.96)

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        DayHeader(store: store)

                        ForEach(store.slots.indices, id: \.self) { index in
                            SlotRow(
                                slot: $store.slots[index],
                                time: store.timeLabel(index: index),
                                endTime: store.endLabel(index: index)
                            )
                            .id(index)
                        }

                        Text("Смена \(ShiftConfig.shiftTitle) · \(ShiftConfig.slotCount) ячеек по \(ShiftConfig.slotMinutes) минут")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
                .background(background.ignoresSafeArea())
                .scrollDismissesKeyboard(.interactively)
                .onAppear { scrollToCurrentSlot(proxy) }
                .onChange(of: store.day) { _ in
                    withAnimation {
                        proxy.scrollTo(0, anchor: .top)
                    }
                }
            }
            .navigationTitle("Смена")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showsClearConfirm = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Очистить день")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        hideKeyboard()
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                TotalsBar(store: store)
            }
        }
        .tint(accent)
        .alert("Очистить день?", isPresented: $showsClearConfirm) {
            Button("Отмена", role: .cancel) {}
            Button("Очистить", role: .destructive) {
                store.clearDay()
                Haptics.warning()
            }
        } message: {
            Text("Все записи за \(store.dayTitle.lowercased()) будут удалены. Вернуть их будет нельзя.")
        }
    }

    private func scrollToCurrentSlot(_ proxy: ScrollViewProxy) {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let minutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        let index = (minutes - ShiftConfig.startTotalMinutes) / ShiftConfig.slotMinutes
        guard index >= 0, index < store.slots.count else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut) {
                proxy.scrollTo(index, anchor: .center)
            }
        }
    }
}
