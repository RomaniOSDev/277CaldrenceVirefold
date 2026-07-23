import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var page = 0

    private let pages: [(title: String, body: String, image: String, symbol: String)] = [
        ("Categorize Music", "Easily categorize your music collection with personalized tags.", "img_banner", "music.note.list"),
        ("Tag Tracks", "Tap on a song to add customized tags like mood, genre, or event.", "img_card", "tag.circle.fill"),
        ("Get Started", "Begin by adding your first song and tagging it.", "img_accent", "play.circle.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    onboardingPage(pages[index], index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.35), value: page)

            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.35))
                        .frame(width: index == page ? 28 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: page)
                }
            }
            .padding(.bottom, 18)

            Button {
                HapticService.medium()
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    store.completeOnboarding()
                }
            } label: {
                Text(page < pages.count - 1 ? "Continue" : "Start Listening")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground").ignoresSafeArea())
    }

    private func onboardingPage(_ item: (title: String, body: String, image: String, symbol: String), index: Int) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.28), Color("AppSurface")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(item.image)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.42)
                    .allowsHitTesting(false)

                LinearGradient(
                    colors: [
                        Color("AppBackground").opacity(0.15),
                        Color("AppBackground").opacity(0.72)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color("AppBackground").opacity(0.55))
                            .frame(width: 112, height: 112)
                        Circle()
                            .stroke(Color("AppPrimary").opacity(0.85), lineWidth: 2.5)
                            .frame(width: 112, height: 112)
                            .rotationEffect(.degrees(index == page ? 8 : 0))
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: page)
                        Image(systemName: item.symbol)
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(Color("AppPrimary"))
                    }

                    Text(item.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 20)
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.45), radius: 20, y: 12)
            .padding(.horizontal, 28)

            Text(item.body)
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 28)

            Spacer()
        }
    }
}
