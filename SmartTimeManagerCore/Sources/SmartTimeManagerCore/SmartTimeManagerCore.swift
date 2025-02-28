import SwiftUI

public struct SmartTimeManagerCoreView: View {
    public init() {}
    
    private let needUpdateCoreDataSchema = false
    @State private var coreDataSchemaUpdated = false
    
    public var body: some View {
        if needUpdateCoreDataSchema {
            if coreDataSchemaUpdated {
                Text("CoreData Schema has been updated")
            } else {
                Button("Update CoreData Schema") {
                    CoreDataWrapper.updateCoreDataSchema()
                    coreDataSchemaUpdated = true
                }
            }
        } else {
            SmartTimeManagerView<RealDI>()
        }
    }
}
