namespace bpm.Logging
{
    public enum ExitCode
    {
        SUCCESS,
        INVALID_REPO,
        REPO_CLONE_FAILED,
        PACKAGE_NOT_FOUND,
        PACKAGE_UP_TO_DATE,
        VERSION_PARSE_FAILED,
        INVALID_ARGUMENTS,
        NET_ERROR,
        UNHANDLED_EXCEPTION
    }
}