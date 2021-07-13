//
//  ViewController.swift
//  mrimg
//
//  Created by Atul Phadke on 5/27/21.
//

import Cocoa
import PythonKit
import Foundation

class ViewController: NSViewController, NSComboBoxDelegate {

    @IBOutlet var imgbutton: NSButton!
    
    @IBOutlet var filebutton: NSButton!
    
    @IBOutlet var scrollView: NSScrollView!
    
    @IBOutlet var new_directory_path: NSButton!
    
    @IBOutlet var new_directory_label: NSTextField!
    
    @IBOutlet var analyze_file_picker: NSButton!
    
    var file1:URL! = nil
    
    var file2:String! = nil
    
    var chosen_file:String! = nil
    
    var analyze_image_array:Array<NSImage>! = []
    
    var analyze_image_array_dim2: Array<Array<NSImage>>! = []
    
    @IBOutlet var Split3D: NSButton!
    
    @IBOutlet var file1_type: NSComboBox!
    
    @IBOutlet var file2_type: NSComboBox!
    
    @IBOutlet var directory_outlet: NSButton!
    
    @IBOutlet var file1_label: NSTextField!
    
    @IBOutlet var new_file_name: NSTextField!
    
    var plantDirectory: URL!
    
    var nib: PythonObject! = nil
    
    var np: PythonObject! = nil
    
    var itk: PythonObject! = nil
    
    var scipy: PythonObject! = nil
    
    var pil: PythonObject! = nil
    
    @IBOutlet var convert_button: NSButton!
    
    var imgio: PythonObject! = nil
    
    var l_destroy3dim: Bool = true
    
    var bruker2dseq_files:Array<URL>! = []
    
    var directory_analysis = false
    
    //let nib = Python.import("nibabel")
    
    //let sys = Python.import("sys")
    
    let mask_view = NSView()
    
    @IBOutlet var stepperImageDim2: NSStepper!
    
    @IBOutlet var stepperImageDim2Label: NSTextField!
    
    @IBOutlet var stepperImageDim1: NSStepper!
    
    @IBOutlet var stepperImageDim1Label: NSTextField!
    
    @IBOutlet var analyze_viewe: NSView!
    
    @IBOutlet var GLOBAL_IMAGE_VIEWER: NSImageView!
    
    @IBOutlet var reset_settings: NSButton!
    
    var dim1Counter = 0
    
    var dim2Counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mask_view.frame = scrollView.frame
        
        analyze_viewe.layer?.backgroundColor = NSColor(red: 36/255, green: 36/255, blue: 39/255, alpha: 0.0).cgColor
        view.addSubview(analyze_viewe)
        
        for v in self.analyze_viewe.subviews {
            v.alphaValue = 0.0
            v.isHidden = true
        }
        stepperImageDim1.minValue = 1
        stepperImageDim2.minValue = 1
        
        PythonLibrary.useVersion(Int(3.8))
    
        let sys = Python.import("sys")
        np = Python.import("numpy")
        itk = Python.import("SimpleITK")
        scipy = Python.import("scipy.misc")
        pil = Python.import("PIL")
        imgio = Python.import("imageio")
        //print(Bundle.main.url(forResource: "main", withExtension: "py"))
        var bundle_path = Bundle.main.url(forResource: "main", withExtension: "py")
        
        sys.path.append(bundle_path?.deletingLastPathComponent().path)
        let classPath = Python.import("main")
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1.0).cgColor
        new_directory_label.alphaValue = 0.0
        new_directory_label.stringValue = ""
        new_directory_path.alphaValue = 0.5
        new_directory_path.isEnabled = false
        
        self.file1_type.delegate = self
        
        GLOBAL_IMAGE_VIEWER.imageScaling = .scaleAxesIndependently
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func reset_settings(_ sender: Any) {
        file1_type.deselectItem(at: file1_type.indexOfSelectedItem)
        file2_type.deselectItem(at: file2_type.indexOfSelectedItem)
        new_directory_label.stringValue = ""
        new_file_name.stringValue = ""
        file1 = nil
        file2 = nil
        plantDirectory = nil

    }
    
    func disable() {
        file1_type.isEnabled = false
        file1_type.isHidden = true
        file2_type.isEnabled = false
        file2_type.isHidden = true
        directory_outlet.isEnabled = false
        directory_outlet.isHidden = true
        new_directory_path.isEnabled = false
        new_directory_path.isHidden = true
    }
    
    func enable() {
        file1_type.isEnabled = true
        file1_type.isHidden = false
        file2_type.isEnabled = true
        file2_type.isHidden = false
        directory_outlet.isEnabled = true
        directory_outlet.isHidden = false
        new_directory_path.isEnabled = true
        new_directory_path.isHidden = false
    }
    
    @IBAction func fileconverter(_ sender: Any) {
        self.filebutton.isBordered = true
        self.imgbutton.isBordered = false
        enable()
        self.analyze_viewe.layer?.backgroundColor = NSColor(red: 36/255, green: 36/255, blue: 39/255, alpha: 0.0).cgColor
        for v in self.analyze_viewe.subviews {
            v.alphaValue = 0.0
            v.isHidden = true
        }
        
    }
    @IBAction func changed_folder(_ sender: Any) {
        if self.directory_outlet.intValue == 1 {
            new_directory_label.alphaValue = 0.0
            new_directory_path.alphaValue = 0.5
            new_directory_path.isEnabled = false
            
        } else if self.directory_outlet.intValue == 0 {
            new_directory_label.alphaValue = 1.0
            new_directory_path.alphaValue = 1
            new_directory_path.isEnabled = true
        }
    }
    
    @IBAction func imganalyze(_ sender: Any) {
        self.filebutton.isBordered = false
        self.imgbutton.isBordered = true
        disable()
        self.analyze_viewe.layer?.backgroundColor = NSColor(red: 36/255, green: 36/255, blue: 39/255, alpha: 1.0).cgColor
        for v in self.analyze_viewe.subviews {
            v.alphaValue = 1.0
            v.isHidden = false
        }
    }
    @IBAction func start_converting(_ sender: Any) {
        if self.compile() {
            self.convert()
        }
    }
    
    @IBAction func dim1Changer(_ sender: Any) {
        print("dim1")
        
        let val = Int(stepperImageDim1.floatValue)
        
        stepperImageDim1.maxValue = Double(dim1Counter)
        
        if val <= dim1Counter {
            stepperImageDim1Label.stringValue = "\(Int(stepperImageDim1.floatValue))/\(dim1Counter)"
        }
        changeImage()
    }
    
    @IBAction func dim2Changer(_ sender: Any) {
        print("dim2")
        
        let val = Int(stepperImageDim2.floatValue)
        
        stepperImageDim2.maxValue = Double(dim2Counter)
        
        if val <= dim2Counter {
            stepperImageDim2Label.stringValue = "\(Int(stepperImageDim2.floatValue))/\(dim2Counter)"
        }
        changeImage()
    }
    
    func changeImage() {
        if l_destroy3dim == false {
            GLOBAL_IMAGE_VIEWER.image = analyze_image_array_dim2[Int(stepperImageDim1.floatValue-1)][Int(stepperImageDim2.floatValue-1)]
            print(Int(stepperImageDim1.floatValue-1), Int(stepperImageDim2.floatValue-1))
        } else if l_destroy3dim == true {
            GLOBAL_IMAGE_VIEWER.image = analyze_image_array[Int(stepperImageDim2.floatValue-1)]
        }
    }
    
    
    @IBAction func analyze_get_file(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["nii", "dcm"]
        let clicked = panel.runModal()
        
        if clicked == NSApplication.ModalResponse.OK {
            chosen_file = panel.url?.path
            if chosen_file.hasSuffix(".nii") {

                var itk_img = itk.ReadImage(chosen_file)
                var img = itk.GetArrayFromImage(itk_img)
                
                let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                
                print(img.shape)
                print(img.shape.count)
                
                if img.shape.count == 3 {
                    l_destroy3dim = true
                    dim1Counter = 0
                    dim2Counter = img.count
                    stepperImageDim2.maxValue = Double(img.count - 1)
                    stepperImageDim1Label.alphaValue=0.5
                    stepperImageDim1.alphaValue=0.5
                    for (idx, img_r) in img.enumerated() {
                        imgio.imwrite(paths.appendingPathComponent("mrimg/img-\(idx).png").path, img_r)
                        //scipy.imsave(paths.appendingPathComponent("img-\(idx)").path)
                    }
                } else if img.shape.count > 3 {
                    l_destroy3dim = false
                    dim1Counter = img.count
                    dim2Counter = img[0].count
                    for (idx, img_r) in img.enumerated() {
                        for (jdx, img_q) in img_r.enumerated() {
                            imgio.imwrite(paths.appendingPathComponent("mrimg/img-\(idx)-\(jdx).png").path, img_q)
                            //scipy.imsave(paths.appendingPathComponent("img-\(idx)-\(jdx)").path)
                        }
                    }
                    print(dim1Counter)
                    print(dim2Counter)
                }
                load_imgs()
                if l_destroy3dim == true {
                    
                    GLOBAL_IMAGE_VIEWER.image = analyze_image_array![0]
                    stepperImageDim1Label.stringValue = "1/\(dim1Counter)"
                } else if l_destroy3dim == false {
                    GLOBAL_IMAGE_VIEWER.image = analyze_image_array_dim2![0][0] as! NSImage
                    stepperImageDim2Label.stringValue = "1/\(dim2Counter)"
                    stepperImageDim1Label.stringValue = "1/\(dim1Counter)"
                }
            } else if chosen_file.hasSuffix(".dcm") {
                
            }
        }
    }
    
    func load_imgs() {
        if l_destroy3dim == true {
            var images_path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            images_path = images_path.appendingPathComponent("mrimg")
            var analyze_string_image_array = try! FileManager.default.contentsOfDirectory(at: images_path, includingPropertiesForKeys: .none)
            for idx in 0 ... analyze_string_image_array.count - 1 {
                analyze_image_array?.append(NSImage(contentsOfFile: analyze_string_image_array[idx].path)!)
            }
            //analyze_image_array
        } else if l_destroy3dim == false {
            var images_path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            images_path = images_path.appendingPathComponent("mrimg")
            var analyze_string_image_array = try! FileManager.default.contentsOfDirectory(at: images_path, includingPropertiesForKeys: .none)
            var appending_image_array = [Int: NSImage]()
            for counter in 0 ... dim1Counter - 1 {
                for file in analyze_string_image_array {
                    if file.lastPathComponent.lowercased().starts(with: "img-\(counter)-") {
                        let key = Int(file.lastPathComponent.replacingOccurrences(of:"img-\(counter)-", with: "").replacingOccurrences(of: ".png", with: ""))
                        print(key)
                        try! appending_image_array[key!] = NSImage(contentsOfFile: file.path)!
                        print(file.path)
                        print("here")
                    }
                }
                
                let sorted_image_dict = appending_image_array.sorted(by: { $0.key < $1.key }).map(\.value)
                
                analyze_image_array_dim2!.append(sorted_image_dict)
                appending_image_array.removeAll()
            }
        }
    }
    
    func get_files_from_study(studyURL: URL) {
        var subdirectories = try! studyURL.subDirectories()
        subdirectories =  subdirectories.filter{ $0.lastPathComponent != "AdjResult" }
        
        for file in subdirectories {
            let subfile = file.appendingPathComponent("pdata")
            var subfilesubdirectories = try! subfile.subDirectories()
            for subfiles in subfilesubdirectories {
                bruker2dseq_files.append(subfiles.appendingPathComponent("2dseq"))
            }
        }
    }
    @IBAction func choose_directory(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        let clicked = panel.runModal()
        
        if clicked == NSApplication.ModalResponse.OK {
            print("URLS => \(panel.urls)")
            plantDirectory = panel.urls[0]
            new_directory_label.alphaValue = 1.0
            new_directory_label.stringValue = "\(plantDirectory.lastPathComponent)"
        }
    }
    @IBAction func get_first_file(_ sender: Any) {
        if file1_type.objectValueOfSelectedItem == nil {
            let alert = NSAlert()
            alert.messageText = "Please select the file type."
            alert.informativeText = "You have not filled out one or more file type boxes."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            if file1_type.objectValueOfSelectedItem as! String == "bruker 2dseq" {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.canChooseFiles = true
                panel.allowsMultipleSelection = false
                panel.allowedFileTypes = [""]
                let clicked = panel.runModal()
                
                if clicked == NSApplication.ModalResponse.OK {
                    print("URLS => \(panel.urls)")
                    if panel.urls[0].hasDirectoryPath {
                        get_files_from_study(studyURL: panel.urls[0])
                        file1 = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                        file1_label.stringValue = panel.urls[0].lastPathComponent
                        directory_analysis = true
                    } else {
                        file1 = panel.urls[0]
                        file1_label.stringValue = file1.lastPathComponent
                        directory_analysis = false
                    }
                }
                
            } else if file1_type.objectValueOfSelectedItem as! String == "dicom" {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                panel.allowsMultipleSelection = false
                panel.allowedFileTypes = ["dicom"]
                let clicked = panel.runModal()
                
                if clicked == NSApplication.ModalResponse.OK {
                    print("URLS => \(panel.urls)")
                    file1 = panel.urls[0]
                    file1_label.stringValue = file1.lastPathComponent
                }
                
            } else if file1_type.objectValueOfSelectedItem as! String == "nifti" {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                panel.allowsMultipleSelection = false
                panel.allowedFileTypes = ["nii"]
                let clicked = panel.runModal()
                
                if clicked == NSApplication.ModalResponse.OK {
                    print("URLS => \(panel.urls)")
                    file1 = panel.urls[0]
                    file1_label.stringValue = file1.lastPathComponent
                }
            }
        }
    }
    
    @discardableResult
    func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        file1 = nil
        file1_label.stringValue = "Please choose a file or a directory."
    }
    
    func compile() -> Bool {
        file2 = new_file_name.stringValue
        
        if file1_type.stringValue == file2_type.stringValue {
            let alert = NSAlert()
            alert.messageText = "Change the converted file type."
            alert.informativeText = "You have selected the same file type for both categories, Ex. Dicom and Dicom. Change one of them to proceed."
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return false
        }
        if file1 == nil || file2 == nil || file1_type.stringValue == "" || file2_type.stringValue == "" {
            
            let alert = NSAlert()
            alert.messageText = "Please select a file."
            alert.informativeText = "One or more files have not been selected or filled out."
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return false
        } else {
            if directory_outlet.intValue == 1 {
                plantDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            } else {
                if plantDirectory == nil {
                    let alert = NSAlert()
                    alert.messageText = "Please select an output directory."
                    alert.informativeText = "Your file needs to be outputted somewhere, so select which directory it should be."
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                    return false
                }
            }
            return true
        }
    }
    
    func convert() {
        let classPath = Python.import("main")
        print(self.Split3D.floatValue)
        
        if directory_analysis {
            for (idx, file) in bruker2dseq_files.enumerated() {
                classPath.convert(file1_type.stringValue, file2_type.stringValue, file.path, self.plantDirectory.path+"/"+self.file2 + "\(idx)", self.Split3D.floatValue)
            }
        } else {
        
            classPath.convert(file1_type.stringValue, file2_type.stringValue, self.file1.path, self.plantDirectory.path+"/"+self.file2, self.Split3D.floatValue)
        }
        let alert = NSAlert()
        alert.messageText = "Success!"
        alert.informativeText = "Your new \(file2_type.stringValue) file is now in \(self.plantDirectory.path)"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "View in finder")
        let modalResult = alert.runModal()
        switch modalResult {
        case .alertFirstButtonReturn:
            print("Ok")
        case .alertSecondButtonReturn:
            print("Open in Finder")
            
            NSWorkspace.shared.open(URL(fileURLWithPath: self.plantDirectory.path))
            
        default:
            print("placeholder")
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension URL {
    func subDirectories() throws -> [URL] {
        // @available(macOS 10.11, iOS 9.0, *)
        guard hasDirectoryPath else { return [] }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
    }
}
