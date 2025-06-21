import Charts
import SwiftUI

@ChartContentBuilder
func ChartRuleMark(value: Double?, index: Int, type: String, unit: String, toInt: Bool = false) -> some ChartContent {
    if value != nil && value! > 0 {
        RuleMark(x: .value(type, index))
            .lineStyle(.init(dash: [2, 2]))
            .cornerRadius(8)
            .offset(x: 0, y: 12)
            .annotation(position: .automatic, overflowResolution: .init(x: .fit(to: .plot), y: .fit(to: .plot))) {
                VStack {
                    Text(String(describing: "\(toInt == true ? String(describing: Int(value!)) : String(describing: formatNumber(value: NSNumber(value: value!), digits: 1)!)) \(unit)"))
                        .fontWeight(.semibold)
                }
                .padding(8)
                .background(Material.thick)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
    }
}
