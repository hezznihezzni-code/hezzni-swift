import SwiftUI

struct EarningsBalanceCard: View {
    var balance: String = "55.66 MAD"
    var showButtons: Bool = true
    var onWithdraw: (() -> Void)? = nil
    var onViewHistory: (() -> Void)? = nil
    var body: some View {
        VStack(alignment: .center, spacing: 13) {
            HStack{
                Spacer()
                VStack(spacing: 0) {
                    Text("Earnings Balance")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(.white)
                    Text(balance)
                        .font(Font.custom("Poppins", size: 30).weight(.medium))
                        .foregroundColor(.white)
                    Text("Earnings ready to withdraw")
                        .font(Font.custom("Poppins", size: 10))
                        .foregroundColor(Color(red: 1, green: 1, blue: 1).opacity(0.80))
                }
                .padding(EdgeInsets(top: 5, leading: 4, bottom: 0, trailing: 4))
                Spacer()
            }
            if showButtons == true {
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        onWithdraw?()
                    }){
                        HStack(spacing: 12) {
                            Spacer()
                            Text("Withdraw")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(Color(red: 0.01, green: 0.50, blue: 0.14))
                            Spacer()
                        }
                        .padding(10)
                        .frame(height: 45)
                        .background(Color(red: 1, green: 1, blue: 1).opacity(0.85))
                        .cornerRadius(10)
                    }
                    Button(action: {
                        onViewHistory?()
                    }){
                        HStack(spacing: 12) {
                            Spacer()
                            Text("View Histroy")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(10)
                        .frame(height: 45)
                        .background(Color(red: 1, green: 1, blue: 1).opacity(0.20))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(15)
        .background(
        LinearGradient(
        stops: [
        Gradient.Stop(color: Color(red: 0.27, green: 0.74, blue: 0.4), location: 0.00),
        Gradient.Stop(color: Color(red: 0.14, green: 0.51, blue: 0.24), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
        )
        )
        .cornerRadius(15)
        .padding(.top, 10)
        .shadow(
            color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 20
        )
    }
}

struct EarningsBarChartCard: View {
    let earnings: String = "144.01 MAD"
    let barHeights: [CGFloat] = [0, 0, 0, 21, 110, 39, 14, 8]
    let barLabels = ["12 AM", "3 AM", "6 AM", "9 AM", "12 PM", "3 PM", "6 PM", "9 PM"]
    let yLabels = ["0", "25", "50", "100"]
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Total Earnings")
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                Text(earnings)
                    .font(Font.custom("Poppins", size: 22).weight(.medium))
                    .foregroundColor(.black)
            }
            ZStack {
                // Y-Axis Labels
                ForEach(0..<yLabels.count, id: \ .self) { i in
                    Text(yLabels[i])
                        .font(Font.custom("Poppins", size: 10))
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        .offset(x: -140, y: CGFloat(56 - i * 43))
                }
                // Grid Lines
                ForEach(0..<yLabels.count, id: \ .self) { i in
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 289.72, height: 0.55)
                        .background(Color.clear)
                        .overlay(
                            Rectangle()
                                .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.55)
                        )
                        .offset(x: 17.56, y: CGFloat(61 - i * 43))
                }
                // Bar Chart
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<barHeights.count, id: \ .self) { i in
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 25, height: barHeights[i])
                            .background(i < 3 ? Color(red: 0.77, green: 0.88, blue: 0.80) : Color(red: 0.22, green: 0.65, blue: 0.33))
                            .cornerRadius(5.11)
                    }
                }
                .frame(width: 292, height: 110)
                .offset(x: 17.76, y: 5.94)
                // X-Axis Labels
                HStack(spacing: 15) {
                    ForEach(barLabels, id: \ .self) { label in
                        Text(label)
                            .font(Font.custom("Poppins", size: 9))
                            .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                    }
                }
                .frame(width: 293)
                .offset(x: 17.41, y: 80)
            }
            .frame(width: 327.82, height: 171.01)
        }
        .padding(EdgeInsets(top: 20, leading: 17, bottom: 20, trailing: 17))
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .inset(by: 0.50)
                .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
        )
        .shadow(
            color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 10
        )
    }
}

struct EarningsStatsCard: View {
    var onlineTime: String = "11h 22m"
    var totalTrips: String = "5"
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack{
                    Text("Online Time")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                    Spacer()
                }
                Text(onlineTime)
                    .font(Font.custom("Poppins", size: 20).weight(.medium))
                    .foregroundColor(.black)
                
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .inset(by: 0.50)
                    .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
            )
            .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 10
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack{
                    Text("Total Trips")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                    Spacer()
                }
                Text(totalTrips)
                    .font(Font.custom("Poppins", size: 20).weight(.medium))
                    .foregroundColor(.black)
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .inset(by: 0.50)
                    .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
            )
            .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 10
            )
        }
        .padding(.horizontal, 20)
    }
}

struct EarningScreen: View {
    @State private var selectedTab: String = "Today"
    let tabs = ["Today", "Weekly", "Monthly"]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingAppBar(title: "Earnings", onBack: {
                dismiss()
            })
            Divider()
            ScrollView {
                VStack(spacing: 13){
                    EarningsBalanceCard(balance: "55.5")
                    // Filter Tabs (segmented style)
                    HStack(spacing: 0) {
                        ForEach(tabs, id: \ .self) { tab in
                            FilterTabPill(title: tab, isSelected: selectedTab == tab)
                                .onTapGesture { selectedTab = tab }
                        }
                    }
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    EarningsBarChartCard()
                    EarningsStatsCard()
                    Spacer()
                }
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

#Preview {
    EarningScreen()
}
