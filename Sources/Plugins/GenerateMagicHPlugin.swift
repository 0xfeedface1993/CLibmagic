//
//  File.swift
//  
//
//  Created by sonoma on 7/28/24.
//

import PackagePlugin
import Foundation

@main
struct GenerateMagicHPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }
        let inputFiles = target.sourceFiles(withSuffix: "in").filter({ $0.path.lastComponent == "magic.h" })
        return try inputFiles.map {
            let inputFile = $0
            let inputPath = inputFile.path
            let outputName = inputPath.stem
            let outputPath = context.pluginWorkDirectory.appending(outputName)
            let command = 
"""
"s/X.YY/$(echo "5.45" | tr -d .)/"
"""
            return .buildCommand(
                displayName: "Generating \(outputName) from \(inputPath.lastComponent)",
                executable: try context.tool(named: "sed").path,
                arguments: [ command, "\(inputPath)", "\(outputPath)" ],
                inputFiles: [ inputPath ],
                outputFiles: [ outputPath ]
            )
        }
    }
}
