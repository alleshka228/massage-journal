import SwiftUI

struct ContentView: View {
    @StateObject private var store = JournalStore()
    @State private var showsCalendar = false

    private let accent = Color(red: 0.05, green: 0.45, blue: 0.41)
    private let background = Color(red: 0.95, green: 0.96, blue: 0.96)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Дата всегда на виду, даже когда список прокручен
                DayHeader(store: store)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 6)
                    .background(background)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.black.opacity(0.07))
                            .frame(height: 0.5)
                    }

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(store.slots.indices, id: \.self) { index in
                                SlotRow(
                                    slot: $store.slots[index],
                                    time: store.timeLabel(index: index),
                                    endTime: store.endLabel(index: index)
                                )
                                .id(index)
                            }

                            footer
                                .padding(.top, 6)
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 4)
                        .padding(.bottom, 20)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onAppear {
                        scrollToCurrentSlot(proxy)
                        // Для скриншотов из симулятора: сразу открыть календарь
                        if ProcessInfo.processInfo.arguments.contains("-showCalendar") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                showsCalendar = true
                            }
                        }
                    }
                    .onChange(of: store.day) { _ in
                        withAnimation {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                }
            }
            .background(background.ignoresSafeArea())
            .navigationTitle("Смена")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showsCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .accessibilityLabel("Выбрать день в календаре")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        hideKeyboard()
                    }
                }
            }
            .sheet(isPresented: $showsCalendar) {
                CalendarSheet(store: store)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                TotalsBar(store: store)
            }
        }
        .tint(accent)
    }

    private var footer: some View {
        Text("Смена \(ShiftConfig.shiftTitle) · \(ShiftConfig.slotCount) ячеек по \(ShiftConfig.slotMinutes) минут")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private func scrollToCurrentSlot(_ proxy: ScrollViewProxy) {
        let index = initialSlotIndex()
        guard index >= 0, index < store.slots.count else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut) {
                proxy.scrollTo(index, anchor: .center)
            }
        }
    }

    /// Куда прокрутить при открытии: текущее время, либо индекс из аргумента -scrollTo (для скриншотов).
    private func initialSlotIndex() -> Int {
        let arguments = ProcessInfo.processInfo.arguments
        if let flag = arguments.firstIndex(of: "-scrollTo"),
           flag + 1 < arguments.count,
           let index = Int(arguments[flag + 1]) {
            return index
        }
        let parts = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let minutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        return (minutes - ShiftConfig.startTotalMinutes) / ShiftConfig.slotMinutes
    }
}
