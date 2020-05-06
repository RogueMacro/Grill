using System;

namespace bpm
{
    public enum ExitCode
    {
        INVALID_REPO,
        REPO_CLONE_FAILED,
        PACKAGE_NOT_FOUND,
        PACKAGE_UP_TO_DATE,
        VERSION_PARSE_FAILED,
    }
}
