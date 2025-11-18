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
    @NSManaged public var edition: Edition?
    @NSManaged public var owner: Person?
    @NSManaged public var storage: Query?
    
    public var wrappedEdition: Edition {
        if let edition = self.edition {
            return edition
        }
        let fakeEdition = Edition()
        fakeEdition.setIsEdition(newIsEdition: true)
        fakeEdition.setNumber(newNumber: 2024)
        return fakeEdition
    }
    public func setImageData(newImageData: Data) {
        image = newImageData
    }
    public var wrappedImageData: Data {
        
        
        
        
        
        
        
        
        
        image ?? (SimageToUIimage(Image("Image"))?.pngData())!
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
    
    public var wrappedType: String {
        type ?? "_type_"
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
    public func setType(newType: String) {
        type = newType
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    public func SimageToUIimage(_ image: Image) -> UIImage? {
        let controller = UIHostingController(rootView: image)
        let view = controller.view
        
        let targetSize = CGSize(width: 1160, height: 1160)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
    public func setImage(Simage: Image) {
        let uiimage = SimageToUIimage(Simage)
        image = uiimage?.pngData()
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

extension Item : Identifiable {

}
