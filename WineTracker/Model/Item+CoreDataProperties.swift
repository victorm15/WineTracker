import Foundation
import CoreData
import SwiftUI
import UIKit

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    @NSManaged private var creator: String?
    @NSManaged private var domain: String?
    @NSManaged private var drank: Int16
    @NSManaged private var image: Data?
    @NSManaged private var name: String?
    @NSManaged private var quantity: Int16
    @NSManaged private var type: String?
    @NSManaged public var owner: Person?
    /// Whether `editionNumber` is a vintage year rather than an edition number.
    @NSManaged public private(set) var isVintage: Bool
    /// The vintage year or edition number.
    @NSManaged public private(set) var editionNumber: Int16

    public func setEdition(isVintage newIsVintage: Bool, number: Int16) {
        isVintage = newIsVintage
        editionNumber = number
    }
    public func setImageData(newImageData: Data) {
        image = newImageData
    }
    /// The wine's own photo, nil when it uses the placeholder.
    public var storedImageData: Data? {
        image
    }
    public var wrappedName: String {
        name ?? "_name_"
    }
    public var wrappedDomain: String {
        domain ?? "_domain_"
    }

    public var wrappedCreator: String {
        creator ?? "_creator_"
    }
    
    /// nil only if the stored key isn't one `WineType` knows.
    var wineType: WineType? {
        type.flatMap(WineType.init(rawValue:))
    }
    public var wrappedQuantity: Int16 {
        quantity
    }
    public var wrappedDrank: Int16 {
        drank
    }
    public func setName(newName: String) {
        name = newName
    }
    public func setDomain(newDomain: String) {
        domain = newDomain
    }
    public func setCreator(newCreator: String) {
        creator = newCreator
    }
    public func setQuantity(newQuantity: Int16) {
        quantity = newQuantity
    }
    public func setDrank(newDrank: Int16) {
        drank = newDrank
    }
    func setType(_ newType: WineType) {
        type = newType.rawValue
    }
    public var wrappedImage: Image {
        if let data = image, let uiImage = UIImage(data: data) {
            // If data is valid, create an Image from UIImage
            return Image(uiImage: uiImage)
        } else {
            // If data is nil, return a default Image from asset catalog
            return Image("Image")
        }
    }
}

extension Item : Identifiable {}
