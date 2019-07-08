//: Playground - noun: a place where people can play
import PlaygroundSupport
import Cocoa

playgroundSharedDataDirectory

func parsingClass(file path: String) -> (String ,[String])? {

    guard let range = path.range(of:"Tests.swift") ,
        range.isEmpty == false else {
        return nil
    }

    let text = try! String(contentsOfFile: path)

    let regexForTestCase = "func (test[\\w]+)[ ]*\\(\\)"
    let re = try! NSRegularExpression(pattern: regexForTestCase)

    let nsString = NSString(string:text)
    let length = nsString.length
    let results = re.matches(in: text, options: [], range: NSRange(location: 0, length: length))
    let strings = results.map { nsString.substring(with: $0.rangeAt(1))}


    let regexForClassName = "class ([\\w]+)"
    let re2 = try! NSRegularExpression(pattern: regexForClassName)
    let results2 = re2.firstMatch(in: text, options: [], range: NSRange(location: 0, length: length))
    let className = nsString.substring(with: (results2?.rangeAt(1))!)

    return (className,strings)
}

func createTestsFileForLinux(usingFiles files: [String], testsBundle: String) -> String {

    var output = String()

    output += "#if os(Linux)\n"
    output += "\n"
    output += "import XCTest\n"
    output += "@testable import \(testsBundle)\n"

    for file in files {
        if let tuple = parsingClass(file: file) {
            output += "\n    extension \(tuple.0) {\n"
            output += "        static let allTests = [\n"
            for testcase in tuple.1 {
                output += "                (\"\(testcase)\",\(testcase)),\n"
            }
            output += "            ]\n"
            output += "    }\n"
        }
    }
    output += "\n"

    output += "    XCTMain([\n"

    for file in files {2
        if let tuple = parsingClass(file: file) {
            output += "        testCase(\(tuple.0).allTests),\n"
        }
    }

    output += "        ])\n"


    output += "\n#endif"
    
    return output
    
}

func write(this text: String,inside file: String) {

    let url = URL(fileURLWithPath: file)
    do {
        try text.write(to: url, atomically: false, encoding: String.Encoding.utf8)
    }
    catch let error { print(error) }

}

guard let folder = Bundle.main.path(forResource: "Tests", ofType: nil) else {
    exit(0)
}
let url = URL(fileURLWithPath: folder, isDirectory: true)
let mainFolder = url.deletingLastPathComponent()
let fileManager = FileManager.default
var files = [String]()
fileManager.enumerator(atPath: folder)?.forEach{files.append("\(folder)/\($0)")}
let output = createTestsFileForLinux(usingFiles: files, testsBundle: "MyFrameworkTests")

let fileToCreate = "\(mainFolder.path)/Out/LinuxMain.swift"

write(this: output, inside:fileToCreate)
