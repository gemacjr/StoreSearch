//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Ed McCormic on 4/6/17.
//  Copyright © 2017 Swiftbeard. All rights reserved.
//

import UIKit
extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        // 1
        let downloadTask = session.downloadTask(with: url,
                                                // 2
            completionHandler: { [weak self] url, response, error in
                if error == nil, let url = url,
                    let data = try? Data(contentsOf: url),
                    // 3
                    // 4
                    let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            strongSelf.image = image
                        }
                    } }
        })
        // 5
        downloadTask.resume()
        return downloadTask
    }
}
