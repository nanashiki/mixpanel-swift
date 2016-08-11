//
//  InAppNotification.swift
//  Mixpanel
//
//  Created by Yarden Eitan on 8/9/16.
//  Copyright © 2016 Mixpanel. All rights reserved.
//

import Foundation

struct InAppNotification {
    let ID: Int
    let messageID: Int
    let type: String
    let style: String
    let imageURL: URL
    lazy var image: Data? = {
        var data: Data?
        do {
            data = try Data(contentsOf: self.imageURL, options: [.mappedIfSafe])
        } catch {
            Logger.error(message: "image failed to load from url \(self.imageURL)")
        }
        return data
    }()
    let title: String
    let body: String
    let callToAction: String
    let callToActionURL: URL?
}

extension InAppNotification {
    init?(JSONObject: [String: AnyObject]?) {
        guard let object = JSONObject else {
            Logger.error(message: "notification json object should not be nil")
            return nil
        }

        guard let ID = object["id"] as? Int, ID > 0 else {
            Logger.error(message: "invalid notification id")
            return nil
        }

        guard let messageID = object["message_id"] as? Int, messageID > 0 else {
            Logger.error(message: "invalid notification message id")
            return nil
        }

        guard let type = object["type"] as? String else { //todo check if its right types
            Logger.error(message: "invalid notification type")
            return nil
        }

        guard let style = object["style"] as? String else {
            Logger.error(message: "invalid notification style")
            return nil
        }

        guard let title = object["title"] as? String, !title.isEmpty else {
            Logger.error(message: "invalid notification title")
            return nil
        }

        guard let body = object["body"] as? String, !body.isEmpty else {
            Logger.error(message: "invalid notification body")
            return nil
        }

        guard let callToAction = object["cta"] as? String else {
            Logger.error(message: "invalid notification cta")
            return nil
        }

        var callToActionURL: URL?
        if let URLString = object["cta_url"] as? String {
            callToActionURL = URL(string: URLString)
        }

        guard let imageURLString = object["image_url"] as? String,
            let escapedImageURLString = imageURLString
                .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
            let imageURL = URL(string: escapedImageURLString) else {
            Logger.error(message: "invalid notification image url")
            return nil
        }

        var imagePath = imageURL.path
        if type == "takeover" {
            imagePath = "\(imageURL.deletingPathExtension())@2x.\(imageURL.pathExtension)"
        }
        var imageURLComponents = URLComponents()
        imageURLComponents.scheme = imageURL.scheme
        imageURLComponents.host = imageURL.host
        imageURLComponents.path = imagePath

        guard let imageURLParsed = imageURLComponents.url else {
            Logger.error(message: "invalid notification image url")
            return nil
        }

        self.init(ID: ID,
                  messageID: messageID,
                  type: type,
                  style: style,
                  imageURL: imageURLParsed,
                  image: nil,
                  title: title,
                  body: body,
                  callToAction: callToAction,
                  callToActionURL: callToActionURL)
    }



}
