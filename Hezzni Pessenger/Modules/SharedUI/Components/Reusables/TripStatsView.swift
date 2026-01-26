import SwiftUI

struct TripStatsView: View {
    let distance: String
    let totalTime: String
    let price: String

    var titleColor: Color = Color(red: 0.59, green: 0.59, blue: 0.59)
    var valueColor: Color = Color(red: 0, green: 0, blue: 0)
    var priceColor: Color = Color(red: 0.22, green: 0.65, blue: 0.33)
    var backgroundColor: Color = .white
    var cornerRadius: CGFloat = 10
    var shadowColor: Color = Color(red: 0, green: 0, blue: 0, opacity: 0.05)
    var shadowRadius: CGFloat = 30
    var shadowYOffset: CGFloat = 4

    var body: some View {
        HStack {
            Spacer()
                .frame(width: 18)
            // Distance
            VStack {
                Text("Distance")
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(titleColor)
                Text(distance)
                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                    .foregroundColor(valueColor)
            }
            Spacer()
            // Separator
            Rectangle()
                .foregroundColor(Color.black.opacity(0.08))
                .frame(width: 1, height: 41)
                .padding(.horizontal, 6)
            
            // Total Time
            VStack(alignment: .leading) {
                Text("Total Time")
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(titleColor)
                Text(totalTime)
                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                    .foregroundColor(valueColor)
            }
            Spacer()
            // Separator
            Rectangle()
                .foregroundColor(Color.black.opacity(0.08))
                .frame(width: 1, height: 41)
                .padding(.horizontal, 6)

            

            // Price
            VStack(alignment: .leading) {
                Text("Price")
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(titleColor)
                Text(price)
                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                    .foregroundColor(priceColor)
            }
            Spacer()
                .frame(width: 18)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: 0.50)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.50)
        )
        .shadow(color: shadowColor, radius: shadowRadius, y: shadowYOffset)
    }
}


#Preview {
    TripStatsView(distance: "1.3 km", totalTime: "11 min", price: "74 MAD")
        .padding(.horizontal)
        .previewLayout(.sizeThatFits)
}
