import SwiftUI
import UIKit

/// A lightweight camera capture sheet powered by `UIImagePickerController`.
///
/// - Note: Requires `NSCameraUsageDescription` in Info.plist.
struct CameraCaptureView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController

    enum CameraDevice {
        case rear
        case front
    }

    var onImagePicked: (UIImage) -> Void
    var onCancel: () -> Void

    /// Optional camera device preference (best-effort). Default: `.rear`.
    var preferredCameraDevice: CameraDevice = .rear

    /// If true, the returned image is horizontally mirrored. Useful for selfies.
    var shouldMirrorForFrontCamera: Bool = false

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()

        // iPad can crash if the picker is presented with an unsupported style.
        // Force full screen to keep this stable across devices.
        picker.modalPresentationStyle = .fullScreen

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo

            switch preferredCameraDevice {
            case .rear:
                if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                    picker.cameraDevice = .rear
                }
            case .front:
                if UIImagePickerController.isCameraDeviceAvailable(.front) {
                    picker.cameraDevice = .front
                }
            }
        } else {
            // Graceful fallback (e.g. simulator, restricted devices, some iPad configs)
            picker.sourceType = .photoLibrary
        }

        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onImagePicked: onImagePicked,
            onCancel: onCancel,
            shouldMirrorForFrontCamera: shouldMirrorForFrontCamera,
            preferredCameraDevice: preferredCameraDevice
        )
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let onImagePicked: (UIImage) -> Void
        private let onCancel: () -> Void
        private let shouldMirrorForFrontCamera: Bool
        private let preferredCameraDevice: CameraDevice

        init(
            onImagePicked: @escaping (UIImage) -> Void,
            onCancel: @escaping () -> Void,
            shouldMirrorForFrontCamera: Bool,
            preferredCameraDevice: CameraDevice
        ) {
            self.onImagePicked = onImagePicked
            self.onCancel = onCancel
            self.shouldMirrorForFrontCamera = shouldMirrorForFrontCamera
            self.preferredCameraDevice = preferredCameraDevice
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onCancel()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            defer { picker.dismiss(animated: true) }

            guard var image = info[.originalImage] as? UIImage else {
                onCancel()
                return
            }

            if shouldMirrorForFrontCamera, preferredCameraDevice == .front {
                if let cgImage = image.cgImage {
                    image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
                }
            }

            onImagePicked(image)
        }
    }
}
