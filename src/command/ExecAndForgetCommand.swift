import Common

struct ExecAndForgetCommand: Command {
    let args: ExecAndForgetCmdArgs

    func _run(_ state: CommandMutableState, stdin: String) -> Bool {
        // todo shall exec-and-forget fork exec session?
        check(Thread.current.isMainThread)
        // It doesn't throw if exit code is non-zero
        Result { try Process.run(URL(filePath: "/bin/bash"), arguments: ["-c", args.bashScript]) }
            .getOrThrow()
        return true
    }
}
