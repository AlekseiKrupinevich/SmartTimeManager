import Foundation

struct TaskModel {
    let id: String
    var title: String
    var notes: String
    var type: TaskType
    var completionDates: Set<Date>
    
    enum TaskType {
        case oneTime(OneTime)
        case periodic(Periodic)
        
        struct OneTime {
            var date: Date
            let carryOver: Bool
            
            init(date: Date, carryOver: Bool = true) {
                self.date = date
                self.carryOver = carryOver
            }
        }
        
        struct Periodic {
            var timeFrame: TimeFrame
            var type: PeriodType
            
            enum TimeFrame {
                case on(On)
                case off
                
                struct On {
                    var startDate: Date
                    var endDate: Date
                }
            }
            
            enum PeriodType {
                case everyday
                /// Range of values 1 ... 7 (1=Sun, 2=Mon, ..., 7=Sat)
                case weekly(Set<Int>)
                /// Range of values 1 ... 31
                case monthly(Set<Int>)
                case lastDayOfMonth
            }
        }
    }
}
