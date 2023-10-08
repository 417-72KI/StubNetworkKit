import Danger 
import Foundation

// fileImport: DangerSwiftExtensions/Git.swift
// fileImport: DangerSwiftExtensions/Tests.swift

let danger = Danger()

SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Sources"), inline: true)

let git = danger.git

if git.modifiedFiles.contains("LICENSE") {
    danger.fail("Do not modify LICENSE !!")
}

if git.deletedFiles.contains("LICENSE") {
    danger.fail("Do not delete LICENSE !!")
}

try verifyTests(danger: danger)

if let github = danger.github {
    if github.pullRequest.title.lowercased().contains("[wip]") {
        danger.warn("PR is classed as Work in Progress")
    }
}
