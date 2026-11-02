import WidgetKit
import SwiftUI

private let appGroup = "group.com.noorrecite.app"

// MARK: - Daily Ayah Widget

struct DailyAyahEntry: TimelineEntry {
    let date: Date
    let ayahArabic: String
    let ayahTranslation: String
    let ayahRef: String
}

struct DailyAyahProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyAyahEntry {
        DailyAyahEntry(
            date: Date(),
            ayahArabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            ayahTranslation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            ayahRef: "Al-Fatiha 1:1"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyAyahEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyAyahEntry>) -> Void) {
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry()], policy: .after(refresh)))
    }

    private func entry() -> DailyAyahEntry {
        let defaults = UserDefaults(suiteName: appGroup)
        return DailyAyahEntry(
            date: Date(),
            ayahArabic: defaults?.string(forKey: "widget_ayah_arabic") ?? "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            ayahTranslation: defaults?.string(forKey: "widget_ayah_translation") ?? "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            ayahRef: defaults?.string(forKey: "widget_ayah_ref") ?? "Al-Fatiha 1:1"
        )
    }
}

struct DailyAyahWidgetView: View {
    var entry: DailyAyahEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#5145CD"), Color(hex: "#006B5F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.ayahArabic)
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .environment(\.layoutDirection, .rightToLeft)

                Divider()
                    .overlay(Color.white.opacity(0.3))

                Text(entry.ayahTranslation)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                HStack {
                    Text(entry.ayahRef)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("QariVerse")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(14)
        }
    }
}

struct DailyAyahWidget: Widget {
    let kind = "DailyAyahWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyAyahProvider()) { entry in
            DailyAyahWidgetView(entry: entry)
                .widgetURL(URL(string: "qariverse://daily-reflection")!)
        }
        .configurationDisplayName("Daily Ayah")
        .description("A daily verse from the Quran.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Prayer Times Widget

struct PrayerTimesEntry: TimelineEntry {
    let date: Date
    let nextName: String
    let nextTime: String
    let remaining: String
    let prayers: [(name: String, time: String)]
}

struct PrayerTimesProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerTimesEntry {
        PrayerTimesEntry(
            date: Date(),
            nextName: "Dhuhr",
            nextTime: "13:15",
            remaining: "2h 30m",
            prayers: [
                (name: "Fajr", time: "05:12"),
                (name: "Dhuhr", time: "13:15"),
                (name: "Asr", time: "16:45"),
                (name: "Maghrib", time: "19:52"),
                (name: "Isha", time: "21:20"),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerTimesEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerTimesEntry>) -> Void) {
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry()], policy: .after(refresh)))
    }

    private func entry() -> PrayerTimesEntry {
        let defaults = UserDefaults(suiteName: appGroup)
        let nextName = defaults?.string(forKey: "widget_next_prayer") ?? "—"
        let nextTime = defaults?.string(forKey: "widget_next_time") ?? "—"
        let remaining = defaults?.string(forKey: "widget_remaining") ?? "—"

        var prayers: [(name: String, time: String)] = []
        if let json = defaults?.string(forKey: "widget_prayers_json"),
           let data = json.data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            prayers = arr.compactMap { dict in
                guard let n = dict["name"], let t = dict["time"] else { return nil }
                return (name: n, time: t)
            }
        }

        return PrayerTimesEntry(
            date: Date(),
            nextName: nextName,
            nextTime: nextTime,
            remaining: remaining,
            prayers: prayers
        )
    }
}

struct PrayerTimesWidgetView: View {
    var entry: PrayerTimesEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#5145CD"), Color(hex: "#006B5F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("NEXT PRAYER")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text(entry.remaining)
                        .font(.caption2)
                        .bold()
                        .foregroundColor(Color(hex: "#FFB957"))
                }

                Text(entry.nextName)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Text(entry.nextTime)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))

                Divider()
                    .overlay(Color.white.opacity(0.3))
                    .padding(.vertical, 4)

                HStack(spacing: 0) {
                    ForEach(entry.prayers.prefix(5), id: \.name) { prayer in
                        VStack(spacing: 2) {
                            Text(prayer.name)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                            Text(prayer.time)
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(12)
        }
    }
}

struct PrayerTimesWidget: Widget {
    let kind = "PrayerTimesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimesProvider()) { entry in
            PrayerTimesWidgetView(entry: entry)
                .widgetURL(URL(string: "qariverse://prayer-times")!)
        }
        .configurationDisplayName("Prayer Times")
        .description("Next prayer and today's schedule.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Reading Streak Widget

struct ReadingStreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let todayCount: Int
    let dailyGoal: Int
    let lastSurah: String
}

struct ReadingStreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReadingStreakEntry {
        ReadingStreakEntry(date: Date(), streak: 7, todayCount: 5, dailyGoal: 10, lastSurah: "Surah Al-Baqarah")
    }

    func getSnapshot(in context: Context, completion: @escaping (ReadingStreakEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReadingStreakEntry>) -> Void) {
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry()], policy: .after(refresh)))
    }

    private func entry() -> ReadingStreakEntry {
        let defaults = UserDefaults(suiteName: appGroup)
        return ReadingStreakEntry(
            date: Date(),
            streak: defaults?.integer(forKey: "widget_streak") ?? 0,
            todayCount: defaults?.integer(forKey: "widget_today_count") ?? 0,
            dailyGoal: defaults?.integer(forKey: "widget_daily_goal") ?? 10,
            lastSurah: defaults?.string(forKey: "widget_last_surah") ?? ""
        )
    }
}

struct ReadingStreakWidgetView: View {
    var entry: ReadingStreakEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#A16800"), Color(hex: "#805200")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(spacing: 2) {
                Text("🔥")
                    .font(.title)

                Text(entry.streak, format: .number)
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)

                Text("day streak")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Divider()
                    .overlay(Color.white.opacity(0.3))
                    .padding(.vertical, 4)

                HStack {
                    Text("Today")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(entry.todayCount)/\(entry.dailyGoal)")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                }

                if !entry.lastSurah.isEmpty {
                    Text(entry.lastSurah)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(14)
        }
    }
}

struct ReadingStreakWidget: Widget {
    let kind = "ReadingStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReadingStreakProvider()) { entry in
            ReadingStreakWidgetView(entry: entry)
                .widgetURL(URL(string: "qariverse://main")!)
        }
        .configurationDisplayName("Reading Streak")
        .description("Track your daily Quran reading streak.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Widget Bundle

@main
struct QariVerseWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyAyahWidget()
        PrayerTimesWidget()
        ReadingStreakWidget()
    }
}

// MARK: - Hex Color Helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

