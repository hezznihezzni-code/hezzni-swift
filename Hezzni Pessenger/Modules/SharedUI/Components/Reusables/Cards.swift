//
//  Cards.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/25/25.
//
import SwiftUI
struct LocationCardView: View {
    let imageName: String
    let heading: String?
    let content: String
    let imageSize: CGFloat
    let iconContainerSize: CGFloat
    let headingColor: Color
    let contentColor: Color
    let trailingIcon: String?
    let onTap: (() -> Void)?
    let cornerRadius: CGFloat
    let roundedEdges: RoundedEdges
    let borderColor: Color
    let time: String?
    let expandToFill: Bool
    
    
    
    enum RoundedEdges {
        case all
        case top
        case bottom
        case none
        
        var corners: UIRectCorner {
            switch self {
            case .all: return [.topLeft, .topRight, .bottomLeft, .bottomRight]
            case .top: return [.topLeft, .topRight]
            case .bottom: return [.bottomLeft, .bottomRight]
            case .none: return []
            }
        }
    }
    
    init(
        imageName: String,
        heading: String? = nil,
        content: String,
        imageSize: CGFloat = 18,
        iconContainerSize: CGFloat = 18,
        headingColor: Color = Color(red: 0.59, green: 0.59, blue: 0.59),
        contentColor: Color = Color(red: 0.09, green: 0.09, blue: 0.09),
        trailingIcon: String? = nil,
        onTap: (() -> Void)? = nil,
        cornerRadius: CGFloat = 8,
        roundedEdges: RoundedEdges = .all,
        borderColor: Color = Color(red: 0.92, green: 0.92, blue: 0.92).opacity(0.60),
        time: String? = "7:19 am",
        expandToFill: Bool = true
        
        
    ) {
        self.imageName = imageName
        self.heading = heading
        self.content = content
        self.imageSize = imageSize
        self.iconContainerSize = iconContainerSize
        self.headingColor = headingColor
        self.contentColor = contentColor
        self.trailingIcon = trailingIcon
        self.onTap = onTap
        self.cornerRadius = cornerRadius
        self.roundedEdges = roundedEdges
        self.borderColor = borderColor
        self.time = time
        self.expandToFill = expandToFill
    }
    
    var body: some View {
        HStack(spacing: 12) {
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
            // Content
            HStack(spacing: 50) {
                VStack(alignment: .leading, spacing: 0) {
                    if heading != nil {
                        Text(heading!)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(headingColor)
                    }
                    
                    Text(content)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .lineLimit(1)
                        .lineSpacing(18)
                        .foregroundColor(contentColor)
                }
                .frame(alignment: .leading)
                
                
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            // Only add a Spacer when we want the card to expand to fill available space
            if expandToFill {
                Spacer()
            }
        }
        
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        
        .background(.white)
        .cornerRadius(8, corners: roundedEdges.corners)
        .overlay(
            RoundedCorner(radius: cornerRadius, corners: roundedEdges.corners)
                .stroke(
                    borderColor,
                    lineWidth: 0.50
                )
        )
        .onTapGesture {
            onTap?()
        }
        // Prevent automatic horizontal expansion when expandToFill == false
        .fixedSize(horizontal: !expandToFill, vertical: false)
    }
}

#Preview{
    LocationCardView(
        imageName: "pickup_ellipse",
        heading: "Pickup",
        content: "Current Location, Marrakech",
        onTap: {},
        roundedEdges: .top
        
    )
    .padding(.horizontal, 16)
}



struct ScheduleCardView: View {
    let title: String
    let dateTime: String
    let icon: String
    let trailingIcon: String?
    let cardWidth: CGFloat?
    let titleColor: Color
    let textColor: Color
    let backgroundColor: Color
    
    let onTap: (() -> Void)?
    
    init(
        title: String = "Pickup time",
        dateTime: String,
        icon: String = "reservation_icon",
        trailingIcon: String? = nil,
        cardWidth: CGFloat? = 362,
        titleColor: Color = Color(red: 0.59, green: 0.59, blue: 0.59),
        textColor: Color = Color(red: 0.09, green: 0.09, blue: 0.09),
        backgroundColor: Color = .white,
        
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.dateTime = dateTime
        self.icon = icon
        self.trailingIcon = trailingIcon
        self.cardWidth = cardWidth
        self.titleColor = titleColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        
        self.onTap = onTap
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(icon)
                .frame(width: 18, height: 18)
                .foregroundStyle(.hezzniGreen)
            
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(titleColor)
                    
                    Text(dateTime)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .lineSpacing(18)
                        .foregroundColor(textColor)
                    
                }
                Spacer()
                
                // Trailing icon
                if let trailingIcon = trailingIcon {
                    Image(trailingIcon)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "#BFBFBF"))
                } else {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        }
        .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.50)
                .stroke(
                    Color(red: 0.92, green: 0.92, blue: 0.92).opacity(0.60),
                    lineWidth: 0.50
                )
        )
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview{
    ScheduleCardView(
        title: "Pickup time",
        dateTime: "16 July, 2025 at 9:00 am",
        icon: "schedule_calendar_icon",
        trailingIcon: "pencil_icon",
        cardWidth: 362,
        onTap: {}
    )
    .padding(.horizontal, 16)
}

// MARK: - Enhanced Horizontal Services Scroll View
struct HorizontalServicesScrollView<Content: View, Data: Identifiable>: View {
    let items: [Data]
    let content: (Data) -> Content
    let spacing: CGFloat
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let showsIndicators: Bool
    let padding: EdgeInsets
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowX: CGFloat
    let shadowY: CGFloat
    let scrollBehavior: ScrollBehavior
    
    enum ScrollBehavior {
        case continuous
        case paging
        case centered
    }
    
    init(
        items: [Data],
        spacing: CGFloat = 12,
        itemWidth: CGFloat = 112,
        itemHeight: CGFloat = 135,
        showsIndicators: Bool = false,
        padding: EdgeInsets = EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4),
        backgroundColor: Color = .white,
        cornerRadius: CGFloat = 0,
        shadowColor: Color = .clear,
        shadowRadius: CGFloat = 0,
        shadowX: CGFloat = 0,
        shadowY: CGFloat = 0,
        scrollBehavior: ScrollBehavior = .continuous,
        @ViewBuilder content: @escaping (Data) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.showsIndicators = showsIndicators
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowX = shadowX
        self.shadowY = shadowY
        self.scrollBehavior = scrollBehavior
        self.content = content
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: showsIndicators) {
                HStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: itemWidth, height: itemHeight)
                            .id(item.id)
                    }
                }
                .padding(padding)
                .background(geometryReader)
            }
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowX, y: shadowY)
        }
    }
    
    private var geometryReader: some View {
        GeometryReader { geometry in
            Color.clear.onAppear {
                // Handle different scroll behaviors if needed
            }
        }
    }
}

// MARK: - Pre-configured Service Card Builder
struct ServiceCardBuilder {
    static func createCard(
        icon: String,
        title: String,
        isSelected: Bool,
        iconSize: CGSize = CGSize(width: 90, height: 90),
        cardSize: CGSize = CGSize(width: 112, height: 120),
        cornerRadius: CGFloat = 12,
        backgroundColor: Color = .white,
        selectedBorderColor: Color = .hezzniGreen,
        unselectedBorderColor: Color = .clear,
        borderWidth: CGFloat = 2,
        shadowColor: Color = Color(hex: "#04060F").opacity(0.06),
        shadowRadius: CGFloat = 10,
        shadowOffset: CGPoint = CGPoint(x: 0, y: 2),
        titleFont: Font = .poppins(.medium, size: 12),
        titleColor: Color = .primary,
        spacing: CGFloat = 8,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: spacing) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize.width, height: iconSize.height)
                
                Text(title)
                    .font(titleFont)
                    .foregroundColor(titleColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: cardSize.width, height: cardSize.height)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(backgroundColor)
                    .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffset.x, y: shadowOffset.y)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isSelected ? selectedBorderColor : unselectedBorderColor, lineWidth: borderWidth)
            )
        }
    }
}

// MARK: - Ride Options Card
struct RideOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let seats: Int
    let timeEstimate: String
    let price: Double
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            // Left Content
            HStack(alignment: .center, spacing: 12) {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.poppins(.medium, size: 16))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        
                        Text(subtitle)
                            .font(.poppins(.regular, size: 12))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                    }
                    
                    HStack(alignment: .center, spacing: 4) {
                        Image("account_icon_filled")
                            .resizable()
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                            .frame(width: 10, height: 11)
                        
                        Text(String(seats) + " · ")
                            .font(.poppins(.regular, size: 12))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                        
                        Text(timeEstimate)
                            .font(.poppins(.regular, size: 12))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                    }
                }
            }
            
            Spacer()
            
            // Right Content
            VStack(alignment: .trailing, spacing: 10) {
                Text(String(price) +  " MAD")
                    .font(.poppins(.semiBold, size: 16))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                
//                Toggle("", isOn: $isSelected)
//                    .toggleStyle(CustomToggleStyle())
//                    .labelsHidden()
//                    .hidden()
            }
            .padding(0)
            .frame(height: 45, alignment: .topTrailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 96, maxHeight: 96, alignment: .center)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.06), radius: 25, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(isSelected ? .hezzniGreen : Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 1)
        )
        .onTapGesture{
            isSelected = !isSelected
        }
    }
}

#Preview{
    @Previewable @State var value = true
    RideOptionCard(
        icon: "car-service-icon",
        title: "Hezzni Comfort",
        subtitle: "Luxury vehicles",
        seats: 4,
        timeEstimate: "5-10 min",
        price: 45,
        isSelected: $value
    )
}


// Custom Toggle Style
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            RoundedRectangle(cornerRadius: 16)

                .fill(configuration.isOn ? .white : Color.gray.opacity(0))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "inset.filled.circle")
                        .foregroundColor(.hezzniGreen)
                        .font(.system(size: 14, weight: .semibold))
                        .opacity(configuration.isOn ? 1 : 0)
                )
        }
    }
}



struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
