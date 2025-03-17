protocol DidBecomeActiveSubscriber {
    var id: String { get }
    func appDidBecomeActive()
}
