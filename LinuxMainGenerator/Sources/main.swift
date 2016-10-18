import Foundation



func parsingClass(file path: String) -> (String ,[String])? {

    if ((path as NSString).pathExtension != "swift") {
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

    for file in files {
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


if CommandLine.arguments.count == 2 {
    print("Invalid usage. Missing the path of tests.")
    exit(1)
}

let path = CommandLine.arguments[1]
let framework = CommandLine.arguments[2]

let fm = FileManager.default
var files = [String]()
fm.enumerator(atPath: "Tests/\(path)/")?.forEach{files.append("Tests/\(path)/\($0)")}
let output = createTestsFileForLinux(usingFiles: files, testsBundle: framework)
let fileToCreate = "Tests/LinuxMain.swift"
write(this: output, inside:fileToCreate)
