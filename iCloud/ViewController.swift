//
//  ViewController.swift
//  iCloud
//
//  Created by Dragon Sky on 8/31/22.
//

import UIKit
import iCloudDocumentSync


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        iCloud.shared().delegate = self
        iCloud.shared().verboseLogging = true
        iCloud.shared().setupiCloudDocumentSync(withUbiquityContainer: nil)
        iCloud.shared().checkAvailability()
        
//        uploadFile()
        downloadFile()
    }

    func uploadFile() {
        let image = UIImage(named: "image.png")
        if let data = image?.jpegData(compressionQuality: 1.0) {
            iCloud.shared().saveAndCloseDocument(withName: "test.png", withContent: data) { cloudDocument, documentData, error in
                print ("save data to iCloud")
                iCloud.shared().updateFiles()
            }
        }
    }
    
    func downloadFile() {
        let fileExists = iCloud.shared().doesFileExist(inCloud: "test.png")
        print ("fileExists: ", fileExists)
        if (fileExists == true) {
            iCloud.shared().retrieveCloudDocument(withName: "test.png") { cloudDocument, documentData, error in
                if (error == nil) {
                    let fileUrl = cloudDocument?.fileURL
                    print ("download data: \(fileUrl)")
                    let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                    let targetURL = tempDirectoryURL.appendingPathComponent("test.png")
                    do {
                        if (FileManager.default.fileExists(atPath: targetURL.path)) {
                            try FileManager.default.removeItem(at: targetURL)
                        }
                        try documentData!.write(to: targetURL)
                    } catch let error {
                        NSLog("Unable to copy file: \(error)")
                    }
                }
            }
        }
    }
}

extension ViewController: iCloudDelegate {
    func iCloudDidFinishInitializingWitUbiquityToken(_ cloudToken: Any!, withUbiquityContainer ubiquityContainer: URL!) {
        print ("Ubiquity container initialized. You may proceed to perform document operations.")
    }
    
    func iCloudAvailabilityDidChange(toState cloudIsAvailable: Bool, withUbiquityToken ubiquityToken: Any!, withUbiquityContainer ubiquityContainer: URL!) {
        print ("iCloudAvailabilityDidChange: ", cloudIsAvailable)
        if (cloudIsAvailable == false) {
            iCloud.shared().checkAvailability()
        } else {
            iCloud.shared().updateFiles()
        }
    }
    
    func iCloudFilesDidChange(_ files: NSMutableArray!, withNewFileNames fileNames: NSMutableArray!) {
        print ("iCloudFilesDidChange: ", fileNames)
    }
}
