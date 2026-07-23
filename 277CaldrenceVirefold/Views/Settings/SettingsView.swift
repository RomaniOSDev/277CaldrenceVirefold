import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SoftCard {
                        VStack(spacing: 0) {
                            NavigationLink {
                                TagRulesView()
                            } label: {
                                settingsRow(title: "Tag Rules", icon: "wand.and.stars")
                            }
                            Divider().background(Color("AppTextSecondary").opacity(0.3))
                            NavigationLink {
                                TagMergeView()
                            } label: {
                                settingsRow(title: "Merge Tags", icon: "arrow.triangle.merge")
                            }
                            Divider().background(Color("AppTextSecondary").opacity(0.3))
                            NavigationLink {
                                ShareCardView()
                            } label: {
                                settingsRow(title: "Share Card", icon: "square.and.arrow.up")
                            }
                            Divider().background(Color("AppTextSecondary").opacity(0.3))
                            NavigationLink {
                                ListeningTimelineView()
                            } label: {
                                settingsRow(title: "Listening History", icon: "clock.arrow.circlepath")
                            }
                        }
                    }

                    actionsCard
                    dangerCard
                }
                .padding(16)
            }
            .screenBackground(opacity: 0.16)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Reset all data?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) {
                    store.resetAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This clears tags, journal entries, stats, and achievements.")
            }
        }
    }

    private var actionsCard: some View {
        SoftCard {
            VStack(spacing: 0) {
                settingsButton(title: "Replay Onboarding", icon: "sparkles") {
                    store.resetOnboarding()
                }
                Divider().background(Color("AppTextSecondary").opacity(0.3))
                settingsButton(title: "Rate Us", icon: "star.fill") {
                    requestReview()
                }
                Divider().background(Color("AppTextSecondary").opacity(0.3))
                settingsButton(title: "Privacy Policy", icon: "hand.raised.fill") {
                    openURL(AppLinks.privacyPolicy)
                }
                Divider().background(Color("AppTextSecondary").opacity(0.3))
                settingsButton(title: "Terms of Use", icon: "doc.text.fill") {
                    openURL(AppLinks.termsOfUse)
                }
            }
        }
    }

    private var dangerCard: some View {
        SoftCard {
            Button {
                showResetConfirm = true
                HapticService.warning()
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(.red)
                    Text("Reset All Data")
                        .foregroundStyle(.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer()
                }
                .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
        }
    }

    private func settingsRow(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: 24)
            Text(title)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(minHeight: 48)
    }

    private func settingsButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticService.light()
            action()
        } label: {
            settingsRow(title: title, icon: icon)
        }
        .buttonStyle(.plain)
    }

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: scene)
        } else if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
