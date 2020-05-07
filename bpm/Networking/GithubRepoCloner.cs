using bpm.Logging;
using bpm.Packages;
using bpm.Utilities;
using LibGit2Sharp;
using System;
using System.IO;

namespace bpm.Networking
{
    public class GithubRepoCloner
    {
        public GithubRepoCloner(string url, string cloneTo)
        {
            Url = url;
            CloneTo = cloneTo;
        }

        public bool Clone(bool force = false)
        {
            Log.Trace("Cloning: " + Url);

            try
            {
                Repository.Clone(Url, CloneTo);
            }
            catch (NameConflictException)
            {
                if (force || Input.GetChoice("Package is already installed. Reinstall?"))
                {
                    //BpmPath.DeleteDirectory(CloneTo);
                    Directory.Delete(CloneTo);
                    Clone();
                }
                else
                    return false;
            }
            catch (Exception e)
            {
                Log.Fatal($"Clone failed: {e.Message}", ExitCode.REPO_CLONE_FAILED);
                return false;
            }

            var validator = new PackageValidator(CloneTo);
            bool valid = validator.Validate();

            return valid;
        }

        public string Url { get; }
        public string CloneTo { get; }
    }
}