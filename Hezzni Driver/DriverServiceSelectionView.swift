import SwiftUI

struct DriverServiceSelectionView: View {
    @StateObject private var vm = DriverServicesViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Select Service")
                .font(.headline)

            if vm.isLoading {
                ProgressView()
            }

            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            List(vm.services) { service in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(service.displayName)
                            .font(.body)
                        Text(service.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: vm.selectedServiceId == service.id ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(vm.selectedServiceId == service.id ? .green : .gray)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.selectedServiceId = service.id
                }
            }
            .listStyle(.plain)

            Button {
                Task { await vm.saveSelection() }
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.selectedServiceId == nil || vm.isLoading)
            .padding(.horizontal)
        }
        .padding(.top)
        .task {
            await vm.loadServices()
        }
        .onChange(of: vm.didSaveSelection) {
            if vm.didSaveSelection {
                dismiss()
            }
        }
    }
}

#Preview {
    DriverServiceSelectionView()
}
