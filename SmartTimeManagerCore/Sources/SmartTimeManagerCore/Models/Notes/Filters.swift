import Foundation
import SwiftUI

struct Filters {
    var appliedFilter: Filter? {
        didSet {
            switch(appliedFilter) {
            case nil:
                UserDefaults.standard.set(nil, forKey: "filterType")
            case .byTag(let text):
                UserDefaults.standard.set("byTag", forKey: "filterType")
                UserDefaults.standard.set(text, forKey: "filterText")
            case .byDate(let dateFilter):
                UserDefaults.standard.set("byDate", forKey: "filterType")
                UserDefaults.standard.set(dateFilter.template, forKey: "filterTemplate")
                UserDefaults.standard.set(
                    dateFilter.from?.timeIntervalSince1970,
                    forKey: "filterFrom"
                )
                UserDefaults.standard.set(
                    dateFilter.to?.timeIntervalSince1970,
                    forKey: "filterTo"
                )
            case .withoutTags:
                UserDefaults.standard.set("withoutTags", forKey: "filterType")
            }
        }
    }
    
    init() {
        let filterType = UserDefaults.standard.string(forKey: "filterType")
        switch filterType {
        case "byTag":
            let text = UserDefaults.standard.string(forKey: "filterText") ?? ""
            appliedFilter = .byTag(text)
        case "byDate":
            Date().timeIntervalSince1970
            let template = UserDefaults.standard.string(forKey: "filterTemplate") ?? ""
            let from = (UserDefaults.standard.value(forKey: "filterFrom") as? Double)
                .map { Date(timeIntervalSince1970: $0) }
            let to = (UserDefaults.standard.value(forKey: "filterTo") as? Double)
                .map { Date(timeIntervalSince1970: $0) }
            appliedFilter = .byDate(.init(template: template, from: from, to: to))
        case "withoutTags":
            appliedFilter = .withoutTags
        default:
            appliedFilter = nil
        }
    }
    
    enum Filter {
        case byTag(String)
        case byDate(DateFilter)
        case withoutTags
        
        var text: String {
            switch self {
            case .byTag(let text):
                return text
            case .byDate(let dateFilter):
                if let from = dateFilter.from, let to = dateFilter.to {
                    let fromText = from.string(template: dateFilter.template)
                    let toText = to.string(template: dateFilter.template)
                    if fromText == toText {
                        return fromText
                    } else {
                        return "\(fromText) – \(toText)"
                    }
                }
                
                if let from = dateFilter.from {
                    let fromText = from.string(template: dateFilter.template)
                    return "\(fromText) – ..."
                }
                
                if let to = dateFilter.to {
                    let toText = to.string(template: dateFilter.template)
                    return "... – \(toText)"
                }
                
                switch dateFilter.template {
                case .dayTemplete:
                    return "Days"
                case .monthTemplete:
                    return "Months"
                case .yearTemplete:
                    return "Years"
                default:
                    return ""
                }
            case .withoutTags:
                return "Without tags"
            }
        }
        
        var color: Color {
            .accentColor
        }
    }
    
    struct DateFilter {
        let template: String
        let from: Date?
        let to: Date?
    }
}
