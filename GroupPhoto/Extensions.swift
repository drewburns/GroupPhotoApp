//
//  Extensions.swift
//  Wingman
//
//  Created by Andrew Burns on 9/1/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    
    public func imageFromServerURL(urlString: String) {
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            DispatchQueue.main.async(execute: { () -> Void in
//                let image = UIImage(data: data!)
                self.image = cachedImage
            })
            return
        }
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }

    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let array = urlString.components(separatedBy: "/")
        let text = array[array.count-1]
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent(text).path
        if FileManager.default.fileExists(atPath: filePath) {
            print("LOADING FROM FILE")
            self.image = UIImage(contentsOfFile: filePath)!
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
//                    let success = self.saveImage(image: downloadedImage, imageName: urlString)
                    
                }
            })
            
        }).resume()
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func saveImage(image: UIImage, imageName: String) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            print("FILE NOT SOMETHING")
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            print("CANT GET DIRECTORY")
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(imageName)!)
            print("SAVED FILE!")
            return true
        } catch {
            print("ERROR", error.localizedDescription)
            return false
        }
    }
    
    func loadImageUsingCacheSync(_ urlString: String) {
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        let session = URLSession.shared.synchronousDataTask(with: url!)
        let data = session.0
        let response = session.1
        let error = session.2
        
        if let error = error {
            print(error)
            return
        }
        
        if let downloadedImage = UIImage(data: data!) {
            imageCache.setObject(downloadedImage, forKey: urlString as NSString)
            
            self.image = downloadedImage
        }
        
    }
    
}



extension String {
    var pairs: [String] {
        var result: [String] = []
        let characters = Array(self.characters)
        stride(from: 0, to: characters.count, by: 2).forEach {
            result.append(String(characters[$0..<min($0+2, characters.count)]))
        }
        return result
    }
    mutating func insert(separator: String, every n: Int) {
        self = inserting(separator: separator, every: n)
    }
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self.characters)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0..<min($0+n, characters.count)])
            if $0+n < characters.count {
                result += separator
            }
        }
        return result
    }
}
extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

func loadImageUsingCacheAsync(_ urlString: String, handler:@escaping (_ image:UIImage?)-> Void) {


    //check cache for image first
    if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
        print("LOADING FROM CACHE")
        handler(cachedImage)
        return
    }
//    if let image_loaded = getSavedImage(named: urlString) {
        let array = urlString.components(separatedBy: "/")
        let text = array[array.count-1]
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent(text).path
        if FileManager.default.fileExists(atPath: filePath) {
            print("LOADING FROM SAVED")
            handler(UIImage(contentsOfFile: filePath)!)
            return
        }


//    }

    //otherwise fire off a new download
    let url = URL(string: urlString)
    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in

        //download hit an error so lets return out
        if let error = error {
            print(error)
            return
        }

//        DispatchQueue.main.async(execute: {

            if let downloadedImage = UIImage(data: data!) {
                imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                print("LOADED FROM WEB :(")
                handler(downloadedImage)
                saveImageLocaly(urlString, image: downloadedImage)
//                let success = self.saveImage(image: downloadedImage, imageName: urlString)

            }
//        })

    }).resume()
}


func loadImageAsync(_ urlString: String, handler:@escaping (_ image:UIImage?)-> Void)
{
    
    let imageURL: URL = URL(string: urlString)!
    
    URLSession.shared.dataTask(with: imageURL) { (data, _, _) in
        if let data = data{
            handler(UIImage(data: data))
        }
        }.resume()
}

func saveImageLocaly(_ url_string: String,image: UIImage) {
    do {
        let array = url_string.components(separatedBy: "/")
        let text = array[array.count-1]
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(text)
        if let pngImageData = UIImagePNGRepresentation(image) {
            print("ABOUT TO SAVE!")
            try pngImageData.write(to: fileURL, options: .atomic)
        }
    } catch { print(error)}
}

//func readImageLocally(_ url_string:String) -> UIImage {
//    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let filePath = documentsURL.appendingPathComponent(url_string).path
//    if FileManager.default.fileExists(atPath: filePath) {
//        return UIImage(contentsOfFile: filePath)!
//    }
//}

