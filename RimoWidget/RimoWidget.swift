
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dday: "", percentage: 0.8, goal: "test", todo: ["첫 번째 할 일", "두 번째 할 일", "세 번째 할 일"])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), dday: "-?", percentage: 0.5, goal: "목표", todo: ["토익 시험", "운동"])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for dayOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, dday: getDday(), percentage: getPercentage(), goal: getGoal(), todo: getTodoList())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func remainDays() -> Int {
        guard let date = UserDefaults.shared.object(forKey: "endDate") as? Date else {
            return Int.min
        }

        let calendar = Calendar.current

        let components = calendar.dateComponents([.day], from: date.onlyDate, to: Date().onlyDate)

        return components.day!
    }

    func getDday() -> String {
        switch remainDays() {
        case let remainDays where remainDays < 0 && remainDays > Int.min:
            return "\(remainDays)"
        case let remainDays where remainDays == Int.min:
            return "-?"
        case let remainDays where remainDays == 0:
            return "-Day"
        case let remainDays where remainDays > 0:
            return "+\(remainDays)"
        default:
            debugPrint("invailid d-day")
            return ""
        }
    }

    func getGoal() -> String {
        return UserDefaults.shared.string(forKey: "goal") ?? "목표를 설정하세요"
    }

    func getTodoList() -> [String] {
        if let todoList = UserDefaults.shared.array(forKey: "\(Date().onlyDate)") as? [String] {
            if todoList.count < 3 && !todoList.isEmpty {
                return todoList
            }else if todoList.isEmpty {
                return ["오늘의 남은 할일이 없습니다"]
            }else {
                return Array(todoList[0...2])
            }
        } else {
            return ["오늘의 남은 할일이 없습니다"]
        }
    }

    func getPercentage() -> Double {
        let startDate = UserDefaults.shared.object(forKey: "startDate") as? Date ?? Date()
        let endDate = UserDefaults.shared.object(forKey: "endDate") as? Date ?? Date()

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate.onlyDate, to: endDate.onlyDate)

        let fullDays = Double(components.day!)

        let remainDays = fullDays + Double(remainDays())
        var percentage = (remainDays + 1) / (fullDays + 1)
        if percentage > 1 { percentage = 1 }

        return percentage
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dday: String
    let percentage: Double
    let goal: String
    let todo: [String]
}

struct RimoWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.colorScheme) var colorScheme

    var entry: Provider.Entry

    var textColor: Color  {
        colorScheme == .dark ? Color.white : Color.black
    }

    var underlineColor: Color {
        colorScheme == .dark ? Color.white : MySpecialColors.WidgetUnderLine
    }

    var backgroundColor: Color {
        colorScheme == .dark ? Color.widgetBackground : Color.white
    }

    var marimoImage: String {
        colorScheme == .dark ? "marimo-face-dark" : "marimo-face-light"
    }

    @ViewBuilder
    var body: some View {
        switch self.family {
        case .systemSmall:
            VStack {
                HStack{
                    Text(entry.goal)
                        .font(.custom("Pretendard-Regular", size: 10))
                        .foregroundStyle(textColor)
                    Spacer()
                }
                HStack{
                    Text("D\(entry.dday)")
                        .font(.custom("Pretendard-SemiBold", size: 28))
                        .foregroundStyle(MySpecialColors.Green4)
                    Spacer()
                }
                Spacer()

                HStack{
                    Spacer()
                    CircularProgressView(progress: entry.percentage, image: marimoImage)
                        .frame(width: 72, height: 72)
                }
            }
            .widgetBackground(backgroundView: backgroundColor)
        case .systemMedium:
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text("To do List")
                        .font(.custom("Pretendard-Bold", size: 16))
                        .foregroundStyle(MySpecialColors.Green4)
                        .frame(alignment: .leading)
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(0..<entry.todo.count, id: \.self) { i in
                            TodoLabel(todo: entry.todo[i],
                                      textColor: textColor,
                                      underlineColor: underlineColor)
                        }
                    }
                    .frame(width: 164, height: 92)
                    Spacer()
                }
                .padding(.leading, 16)


                Spacer()

                VStack(alignment: .leading) {
                    Spacer()
                    Text("D\(entry.dday)")
                        .font(.custom("Pretendard-Bold", size: 16))
                        .foregroundStyle(MySpecialColors.Green4)
                        .frame(alignment: .leading)
                    CircularProgressView(progress: entry.percentage, image: marimoImage)
                        .frame(width: 92, height: 92)
                        .padding(.trailing, 16)
                    Spacer()

                }
            }.widgetBackground(backgroundView: backgroundColor)
        default:
            Text("default")
        }
    }
}

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct TodoLabel: View {
    let todo: String
    let textColor: Color
    let underlineColor: Color

    var body: some View {
        Label {
            Text(todo)
                .font(.custom("Pretendard-Regular", size: 12))
                .foregroundStyle(textColor)
        } icon: {
            Circle()
                .fill(MySpecialColors.Green4)
                .frame(width: 4, height: 4)
        }
        .frame(width: 164, height: 28, alignment: .leading)
        .overlay(Divider()
            .background(underlineColor),
                 alignment: .bottom)
    }
}

struct CircularProgressView: View {
    // 1
    let progress: Double
    let image: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.5),
                    lineWidth: 10
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    MySpecialColors.Green4,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            Image(image)
                .resizable()
                .frame(width: 30, height: 20)
        }
    }
}

struct RimoWidget: Widget {
    let kind: String = "RimoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RimoWidgetEntryView(entry: entry)
                .padding()
                .background(Color("WidgetBackground"))
        }
        .configurationDisplayName("Marimo Widget")
        .description("This is an Marimo widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

extension Date {
    var onlyDate: Date {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: component) ?? Date()
    }
}
