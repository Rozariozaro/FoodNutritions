import SwiftUI

struct MicronutrientListView: View {
    let micronutrients: [Micronutrient]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(micronutrients.enumerated()), id: \.element.name) { item in
                HStack {
                    Text(item.element.name)
                    Spacer()
                    Text(String(format: "%.1f %@", item.element.value, item.element.unit))
                        .foregroundStyle(.secondary)
                }
                if item.offset < micronutrients.count - 1 {
                    Divider()
                }
            }
        }
    }
}

#Preview {
    MicronutrientListView(micronutrients: [
        Micronutrient(name: "Fiber", value: 5.2, unit: "g"),
        Micronutrient(name: "Sodium", value: 120, unit: "mg")
    ])
    .padding()
}
