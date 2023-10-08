import Danger

extension Git {
    var createdOrModifiedFiles: [File] {
        createdFiles + modifiedFiles
    }
}
