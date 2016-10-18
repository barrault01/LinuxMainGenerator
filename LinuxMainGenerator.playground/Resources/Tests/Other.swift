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
