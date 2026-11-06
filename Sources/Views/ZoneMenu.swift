import SwiftUI

/// Выпадающий список зон массажа.
struct ZoneMenu: View {
    @Binding var zone: MassageZone?

    var body: some View {
        Menu {
            ForEach(MassageZone.allCases) { item in
                Button(item.rawValue) {
                    zone = item
                    Haptics.tap()
                }
            }
            if zone != nil {
                Divider()
                Button("Сбросить", role: .destructive) {
                    zone = nil
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(zone?.rawValue ?? "Зона")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(zone == nil ? Color.secondary : Color.accentColor)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(zone == nil ? 0.06 : 0.14))
            )
        }
        .menuOrder(.fixed)
    }
}
