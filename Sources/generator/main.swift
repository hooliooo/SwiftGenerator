
import ArgumentParser
import CodeBuilder
import Foundation
import OpenAPIKit
import Yams

struct Generator: ParsableCommand {

    @Option(name: .shortAndLong, help: "The path to the Swagger v3 JSON file.")
    var filePath: String

//    @Flag(help: "Include a counter with each repetition.")
//    var includeCounter: Bool
//
//    @Argument(help: "The phrase to repeat.")
//    var phrase: String

    mutating func validate() throws {
        guard
            let url = URL(string: self.filePath),
            url.pathExtension == "json" || url.pathExtension == "yaml" ||  url.pathExtension == "yml"
        else {
            throw ValidationError("File must be a JSON or YAML")
        }
    }

    func run() throws {
        let filePathComponents: [Substring] = self.filePath.split(separator: "/")
        let path: String = {
            var path: String = "file://"
            if filePathComponents.count > 1 {
                path += self.filePath
            } else {
                path += FileManager.default.currentDirectoryPath + "/" + self.filePath
            }
            return path
        }()

        let url = URL(string: path)!

        do {
            let openAPI: OpenAPI.Document
            switch url.pathExtension {
                case "json":
                    openAPI = try JSONDecoder().decode(OpenAPI.Document.self, from: try Data(contentsOf: url))
                case "yaml":
                    openAPI = try YAMLDecoder().decode(OpenAPI.Document.self, from: try String(contentsOf: url))
                default:
                    throw ValidationError("File must be a JSON or YAML")
            }
            let (schemas, modelFile): ([ObjectSchema], File) = generateModels(schemas: openAPI.components.schemas, indent: "    ")
            print(modelFile.string)
            generateHttpClient(paths: openAPI.paths, schemas: schemas, indent: "    ")

        } catch {
            let openAPIError = OpenAPI.Error(from: error)
            print(openAPIError.localizedDescription)
        }

    }
}

Generator.main()
