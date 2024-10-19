//
//  Item+CoreDataProperties.swift
//  coretests
//
//  Created by Victor on 19.10.2024.
//
//

import Foundation
import CoreData
import SwiftUI
import UIKit



extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var creator: String?
    @NSManaged public var domain: String?
    @NSManaged public var drank: Int16
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var quantity: Int16
    @NSManaged public var type: String?
    @NSManaged public var owner: Person?
    @NSManaged public var edition: Edition?

    
    public var wrappedEdition: Edition {
        if let edition = self.edition {
            return edition
        }
        let fakeEdition = Edition()
        fakeEdition.isEdition = true
        fakeEdition.number = 2024
        return fakeEdition
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

    private func SimageToUIimage(_ image: Image) -> UIImage? {
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
