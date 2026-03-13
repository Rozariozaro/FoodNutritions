import Foundation

enum HistoryIntent {
    case loadDates
    case selectDate(Date)
    case refresh
    case dismissError
}
