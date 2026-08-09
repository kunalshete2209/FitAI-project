import SwiftUI
import UIKit

enum PDFExporter {
    static func makePDF(for plan: WorkoutPlan) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(plan.title.replacingOccurrences(of: " ", with: "-"))
            .appendingPathExtension("pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        try renderer.writePDF(to: url) { context in
            context.beginPage()
            let inset: CGFloat = 40
            var y: CGFloat = inset

            y = draw(plan.title, size: 28, weight: .bold, y: y, inset: inset)
            y = draw(plan.subtitle, size: 14, weight: .regular, y: y + 4, inset: inset)

            for day in plan.days {
                if y > 650 {
                    context.beginPage()
                    y = inset
                }

                y = draw("\(day.day): \(day.focus)", size: 18, weight: .semibold, y: y + 20, inset: inset)
                y = draw("Warmup: \(day.warmup)", size: 11, weight: .regular, y: y + 8, inset: inset)

                for exercise in day.exercises {
                    y = draw("- \(exercise.name): \(exercise.sets) sets x \(exercise.reps), rest \(exercise.rest). \(exercise.instructions)", size: 11, weight: .regular, y: y + 6, inset: inset)
                }

                y = draw("Cooldown: \(day.cooldown)", size: 11, weight: .regular, y: y + 8, inset: inset)
            }
        }

        return url
    }

    private static func draw(_ text: String, size: CGFloat, weight: UIFont.Weight, y: CGFloat, inset: CGFloat) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size, weight: weight),
            .paragraphStyle: paragraph
        ]
        let rect = CGRect(x: inset, y: y, width: 532, height: 500)
        let height = text.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).height
        text.draw(with: CGRect(x: inset, y: y, width: 532, height: height + 4), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        return y + height + 4
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
