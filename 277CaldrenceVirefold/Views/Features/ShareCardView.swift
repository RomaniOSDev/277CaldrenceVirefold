import SwiftUI

struct ShareCardView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var rendered: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                shareCard
                    .background(
                        GeometryReader { _ in
                            Color.clear.onAppear { renderCard() }
                        }
                    )

                Button {
                    renderCard()
                    guard let rendered else { return }
                    let activity = UIActivityViewController(activityItems: [rendered], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.keyWindow?.rootViewController {
                        root.present(activity, animated: true)
                    }
                    HapticService.success()
                } label: {
                    Text("Share Card")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 20)
        }
        .screenBackground(opacity: 0.16)
        .navigationTitle("Share Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var shareCard: some View {
        let quote = store.shareCardQuote()
        return VStack(alignment: .leading, spacing: 16) {
            Text("HarmonyTrack")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color("AppPrimary"))
            Text("My taste this month")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(quote.tagsLine)
                .font(.headline)
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(3)
            Text("“\(quote.entryLine)”")
                .font(.body.italic())
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(5)
            Spacer(minLength: 0)
            Text("\(store.stats.itemsAdded) tags · \(store.stats.entriesWritten) notes · \(store.stats.streak)d streak")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 320, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color("AppSurface"), Color("AppBackground"), Color("AppPrimary").opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.5), lineWidth: 1.5)
        )
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.4), radius: 18, y: 10)
    }

    @MainActor
    private func renderCard() {
        let renderer = ImageRenderer(content: shareCard.frame(width: 360))
        renderer.scale = UIScreen.main.scale
        rendered = renderer.uiImage
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        windows.first { $0.isKeyWindow } ?? windows.first
    }
}
