import SwiftUI

/// Одна строка сетки: время, фамилия, зона, стоимость.
struct SlotRow: View {
    @Binding var slot: Slot
    let time: String
    let endTime: String

    private let accent = Color(red: 0.05, green: 0.45, blue: 0.41)

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(time)
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .monospacedDigit()
                Text(endTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .frame(width: 50, alignment: .leading)
            .padding(.top, 13)

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    TextField("Фамилия клиента", text: $slot.client)
                        .font(.body.weight(.medium))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit { hideKeyboard() }

                    if !slot.client.isEmpty {
                        Button {
                            slot.client = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 17))
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 46)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.035))
                )

                HStack(spacing: 8) {
                    ZoneMenu(zone: $slot.zone)
                    PriceField(price: $slot.price)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(accent)
                .frame(width: 4)
                .padding(.vertical, 16)
                .opacity(slot.hasData ? 1 : 0)
        }
        .shadow(color: .black.opacity(slot.hasData ? 0.08 : 0.03), radius: 10, y: 3)
    }
}
