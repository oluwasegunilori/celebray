//
//  CelebrayWidget.swift
//  CelebrayWidgetExtension
//

import SwiftUI
import WidgetKit

private let widgetGroupId = "group.com.shegz.celebray"

struct UpcomingItem: Identifiable {
  let id = UUID()
  let title: String
  let daysLabel: String
}

struct CelebrayEntry: TimelineEntry {
  let date: Date
  let header: String
  let items: [UpcomingItem]
}

struct CelebrayProvider: TimelineProvider {
  func placeholder(in context: Context) -> CelebrayEntry {
    CelebrayEntry(
      date: Date(),
      header: "Next up",
      items: [
        UpcomingItem(title: "Alex", daysLabel: "In 3 days"),
        UpcomingItem(title: "Jordan", daysLabel: "Tomorrow"),
      ]
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (CelebrayEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CelebrayEntry>) -> Void) {
    let entry = loadEntry()
    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }

  private func loadEntry() -> CelebrayEntry {
    let prefs = UserDefaults(suiteName: widgetGroupId)
    let header = prefs?.string(forKey: "widget_title") ?? "Next up"
    let json = prefs?.string(forKey: "upcoming_json") ?? "[]"
    let items = parseUpcoming(json)

    return CelebrayEntry(
      date: Date(),
      header: header,
      items: items
    )
  }

  private func parseUpcoming(_ json: String) -> [UpcomingItem] {
    guard let data = json.data(using: .utf8),
      let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
    else {
      return []
    }

    return array.compactMap { dict in
      guard let title = dict["title"] as? String else { return nil }
      let daysLabel = (dict["daysLabel"] as? String) ?? ""
      return UpcomingItem(title: title, daysLabel: daysLabel)
    }
  }
}

struct CelebrayWidgetEntryView: View {
  var entry: CelebrayProvider.Entry

  var body: some View {
    ZStack {
      Color(red: 0.07, green: 0.07, blue: 0.07)
      VStack(alignment: .leading, spacing: 6) {
        Text(entry.header)
          .font(.headline)
          .fontWeight(.bold)
          .foregroundStyle(Color(red: 0.96, green: 0.78, blue: 0.25))

        if entry.items.isEmpty {
          Text("Add celebrations in Celebray")
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.85))
        } else {
          ForEach(entry.items.prefix(3)) { item in
            HStack(alignment: .firstTextBaseline, spacing: 6) {
              Text(item.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(1)
              Spacer(minLength: 4)
              Text(item.daysLabel)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(1)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .padding(14)
    }
  }
}

@main
struct CelebrayWidget: Widget {
  let kind: String = "CelebrayWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: CelebrayProvider()) { entry in
      if #available(iOSApplicationExtension 17.0, *) {
        CelebrayWidgetEntryView(entry: entry)
          .containerBackground(for: .widget) {
            Color(red: 0.07, green: 0.07, blue: 0.07)
          }
      } else {
        CelebrayWidgetEntryView(entry: entry)
      }
    }
    .configurationDisplayName("Celebray")
    .description("See your next celebrations at a glance.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct CelebrayWidget_Previews: PreviewProvider {
  static var previews: some View {
    CelebrayWidgetEntryView(
      entry: CelebrayEntry(
        date: Date(),
        header: "Next up",
        items: [
          UpcomingItem(title: "Sam", daysLabel: "Today"),
          UpcomingItem(title: "Riley", daysLabel: "In 2 days"),
        ]
      )
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
