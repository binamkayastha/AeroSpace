import Common

struct ExecAndWaitCommand: Command {
    let info: CmdStaticInfo = ExecAndWaitCmdArgs.info
    let args: ExecAndWaitCmdArgs

    func _run(_ subject: inout CommandSubject, _ stdout: inout String) -> Bool {
        error("Please don't call _run, use run")
    }

    func _runWithContinuation(_ subject: inout CommandSubject, _ index: Int, _ commands: [any Command]) {
        check(Thread.current.isMainThread)
        let process = Process()
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", args.bashScript]
        process.terminationHandler = { _ in
            DispatchQueue.main.async {
                check(Thread.current.isMainThread)
                refreshSession {
                    var focused = CommandSubject.focused
                    // todo preserve subject in "exec sessions" (when/if "exec sessions" appears)
                    var devNull: String = ""
                    _ = Array(commands[(index + 1)...]).run(&focused, &devNull)
                }
            }
        }
        // It doesn't throw if exit code is non-zero
        try! process.run()
    }
}
