import SwiftUI

/// Поле стоимости сеанса с цифровой клавиатурой.
struct PriceField: View {
    @Binding var price: String

    var body: some View {
        HStack(spacing: 3) {
            TextField("0", text: $price)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.body.weight(.semibold))
                .monospacedDigit()
                .frame(width: 72)
            Text("₽")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .frame(minHeight: 46)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.035))
        )
    }
}
