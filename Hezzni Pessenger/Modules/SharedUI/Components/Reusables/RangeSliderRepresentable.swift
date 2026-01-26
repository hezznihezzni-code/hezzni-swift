import SwiftUI
import UIKit

// MARK: - UIKit RangeSlider control (double-ended slider)

final class RangeSlider: UIControl {
    // Public API
    var minimumValue: Double = 0.0 { didSet { if minimumValue > maximumValue { minimumValue = maximumValue }; clampValues(); setNeedsLayout() } }
    var maximumValue: Double = 1.0 { didSet { if maximumValue < minimumValue { maximumValue = minimumValue }; clampValues(); setNeedsLayout() } }

    var lowerValue: Double = 0.25 { didSet { clampValues(); setNeedsLayout(); if oldValue != lowerValue { sendActions(for: .valueChanged) } } }
    var upperValue: Double = 0.75 { didSet { clampValues(); setNeedsLayout(); if oldValue != upperValue { sendActions(for: .valueChanged) } } }

    var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) { didSet { trackLayer.backgroundColor = trackTintColor.cgColor } }
    var trackHighlightTintColor: UIColor = UIColor.systemGreen { didSet { highlightedTrackLayer.backgroundColor = trackHighlightTintColor.cgColor } }
    var thumbTintColor: UIColor = .white { didSet { lowerThumbView.backgroundColor = thumbTintColor; upperThumbView.backgroundColor = thumbTintColor } }
    var thumbBorderColor: UIColor = .gray { didSet { lowerThumbView.layer.borderColor = thumbBorderColor.cgColor; upperThumbView.layer.borderColor = thumbBorderColor.cgColor } }
    var thumbBorderWidth: CGFloat = 0.5 { didSet { lowerThumbView.layer.borderWidth = thumbBorderWidth; upperThumbView.layer.borderWidth = thumbBorderWidth } }
    var curvaceousness: CGFloat = 1.0 { didSet { setNeedsLayout() } }

    // Layers / subviews
    private let trackLayer = CALayer()
    private let highlightedTrackLayer = CALayer()
    private let lowerThumbView = UIView()
    private let upperThumbView = UIView()

    // Tracking state
    private enum Thumb { case lower, upper, none }
    private var currentThumb: Thumb = .none
    private var previousLocation = CGPoint.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(highlightedTrackLayer)

        lowerThumbView.isUserInteractionEnabled = false
        upperThumbView.isUserInteractionEnabled = false

        addSubview(lowerThumbView)
        addSubview(upperThumbView)

        // Default styling
        trackLayer.backgroundColor = trackTintColor.cgColor
        highlightedTrackLayer.backgroundColor = trackHighlightTintColor.cgColor

        lowerThumbView.backgroundColor = thumbTintColor
        upperThumbView.backgroundColor = thumbTintColor

        lowerThumbView.layer.borderColor = thumbBorderColor.cgColor
        upperThumbView.layer.borderColor = thumbBorderColor.cgColor

        lowerThumbView.layer.borderWidth = thumbBorderWidth
        upperThumbView.layer.borderWidth = thumbBorderWidth

        isExclusiveTouch = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let thumbDiameter = min(bounds.height, 28)
        let trackHeight: CGFloat = 4
        let trackY = bounds.midY - trackHeight / 2
        let inset = thumbDiameter / 2
        let trackFrame = CGRect(x: inset, y: trackY, width: bounds.width - inset * 2, height: trackHeight)
        trackLayer.cornerRadius = trackHeight / 2
        trackLayer.frame = trackFrame

        let lowerCenterX = position(for: lowerValue, in: trackFrame)
        let upperCenterX = position(for: upperValue, in: trackFrame)

        let lowerThumbFrame = CGRect(x: lowerCenterX - thumbDiameter / 2, y: bounds.midY - thumbDiameter / 2, width: thumbDiameter, height: thumbDiameter)
        let upperThumbFrame = CGRect(x: upperCenterX - thumbDiameter / 2, y: bounds.midY - thumbDiameter / 2, width: thumbDiameter, height: thumbDiameter)

        lowerThumbView.layer.cornerRadius = curvaceousness * thumbDiameter / 2
        upperThumbView.layer.cornerRadius = curvaceousness * thumbDiameter / 2

        lowerThumbView.frame = lowerThumbFrame
        upperThumbView.frame = upperThumbFrame

        let highlightX = min(lowerCenterX, upperCenterX)
        let highlightWidth = abs(upperCenterX - lowerCenterX)
        highlightedTrackLayer.cornerRadius = trackHeight / 2
        highlightedTrackLayer.frame = CGRect(x: highlightX, y: trackY, width: highlightWidth, height: trackHeight)

        // Simple shadow to match visual style
        [lowerThumbView, upperThumbView].forEach { thumb in
            thumb.layer.shadowColor = UIColor.black.cgColor
            thumb.layer.shadowOffset = CGSize(width: 0, height: 1)
            thumb.layer.shadowOpacity = 0.15
            thumb.layer.shadowRadius = 3
        }
    }

    private func position(for value: Double, in trackFrame: CGRect) -> CGFloat {
        if maximumValue == minimumValue { return trackFrame.minX }
        let ratio = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
        return trackFrame.minX + ratio * trackFrame.width
    }

    private func value(for position: CGFloat, in trackFrame: CGRect) -> Double {
        if trackFrame.width == 0 { return minimumValue }
        let ratio = Double((position - trackFrame.minX) / trackFrame.width)
        return minimumValue + ratio * (maximumValue - minimumValue)
    }

    private func clampValues() {
        lowerValue = min(max(lowerValue, minimumValue), upperValue)
        upperValue = max(min(upperValue, maximumValue), lowerValue)
    }

    // MARK: - Touch handling

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)

        if lowerThumbView.frame.insetBy(dx: -20, dy: -20).contains(previousLocation) && upperThumbView.frame.insetBy(dx: -20, dy: -20).contains(previousLocation) {
            // If touch is between or on both, pick the closer thumb
            let distanceToLower = abs(previousLocation.x - lowerThumbView.center.x)
            let distanceToUpper = abs(previousLocation.x - upperThumbView.center.x)
            currentThumb = distanceToLower < distanceToUpper ? .lower : .upper
        } else if lowerThumbView.frame.insetBy(dx: -20, dy: -20).contains(previousLocation) {
            currentThumb = .lower
        } else if upperThumbView.frame.insetBy(dx: -20, dy: -20).contains(previousLocation) {
            currentThumb = .upper
        } else {
            currentThumb = .none
        }

        return currentThumb != .none
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard currentThumb != .none else { return false }

        let location = touch.location(in: self)
        let deltaLocation = location.x - previousLocation.x
        previousLocation = location

        let thumbDiameter = min(bounds.height, 28)
        let inset = thumbDiameter / 2
        let trackFrame = CGRect(x: inset, y: bounds.midY - 2, width: bounds.width - inset * 2, height: 4)

        switch currentThumb {
        case .lower:
            let newCenterX = min(max(lowerThumbView.center.x + deltaLocation, trackFrame.minX), upperThumbView.center.x)
            let newValue = value(for: newCenterX, in: trackFrame)
            lowerValue = newValue
        case .upper:
            let newCenterX = max(min(upperThumbView.center.x + deltaLocation, trackFrame.maxX), lowerThumbView.center.x)
            let newValue = value(for: newCenterX, in: trackFrame)
            upperValue = newValue
        case .none:
            break
        }

        sendActions(for: .valueChanged)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        currentThumb = .none
    }
}

// MARK: - SwiftUI wrapper

struct RangeSliderRepresentable: UIViewRepresentable {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double

    var minValue: Double
    var maxValue: Double

    var trackTintColor: UIColor
    var trackHighlightTintColor: UIColor
    var thumbTintColor: UIColor
    var thumbBorderColor: UIColor
    var thumbBorderWidth: CGFloat
    var curvaceousness: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> RangeSlider {
        let slider = RangeSlider(frame: .zero)
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.lowerValue = lowerValue
        slider.upperValue = upperValue

        slider.trackTintColor = trackTintColor
        slider.trackHighlightTintColor = trackHighlightTintColor
        slider.thumbTintColor = thumbTintColor
        slider.thumbBorderColor = thumbBorderColor
        slider.thumbBorderWidth = thumbBorderWidth
        slider.curvaceousness = curvaceousness

        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)

        return slider
    }

    func updateUIView(_ uiView: RangeSlider, context: Context) {
        if uiView.minimumValue != minValue { uiView.minimumValue = minValue }
        if uiView.maximumValue != maxValue { uiView.maximumValue = maxValue }

        if abs(uiView.lowerValue - lowerValue) > 0.0001 { uiView.lowerValue = lowerValue }
        if abs(uiView.upperValue - upperValue) > 0.0001 { uiView.upperValue = upperValue }

        uiView.trackTintColor = trackTintColor
        uiView.trackHighlightTintColor = trackHighlightTintColor
        uiView.thumbTintColor = thumbTintColor
        uiView.thumbBorderColor = thumbBorderColor
        uiView.thumbBorderWidth = thumbBorderWidth
        uiView.curvaceousness = curvaceousness
    }

    final class Coordinator: NSObject {
        var parent: RangeSliderRepresentable

        init(_ parent: RangeSliderRepresentable) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: RangeSlider) {
            let clampedLower = min(max(sender.lowerValue, parent.minValue), parent.maxValue)
            let clampedUpper = max(min(sender.upperValue, parent.maxValue), parent.minValue)

            if clampedLower != parent.lowerValue {
                parent.lowerValue = clampedLower
            }
            if clampedUpper != parent.upperValue {
                parent.upperValue = clampedUpper
            }
        }
    }
}

#if DEBUG
#Preview("Range Slider Demo") {
    struct DemoView: View {
        @State private var range: ClosedRange<Double> = 2003...2021

        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Text("\(Int(range.lowerBound))")
                    Spacer()
                    Text("to")
                    Spacer()
                    Text("\(Int(range.upperBound))")
                }
                .font(.system(size: 14, weight: .medium))

                RangeSliderRepresentable(
                    lowerValue: Binding(
                        get: { range.lowerBound },
                        set: { range = $0...range.upperBound }
                    ),
                    upperValue: Binding(
                        get: { range.upperBound },
                        set: { range = range.lowerBound...$0 }
                    ),
                    minValue: 1990,
                    maxValue: 2025,
                    trackTintColor: UIColor(white: 0.9, alpha: 1.0),
                    trackHighlightTintColor: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0),
                    thumbTintColor: .white,
                    thumbBorderColor: .gray,
                    thumbBorderWidth: 0.5,
                    curvaceousness: 1.0
                )
                .frame(height: 44)
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding()
        }
    }

    return DemoView()
}
#endif
