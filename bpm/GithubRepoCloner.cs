using LibGit2Sharp;
using System;

namespace bpm
{
    public class GithubRepoCloner
    {
        public GithubRepoCloner(string url, string cloneTo)
        {
            Url = url;
            CloneTo = cloneTo;
        }

        public void Clone()
        {
            Console.WriteLine("Cloning");

            try
            {
                Repository.Clone(Url, CloneTo);
            }
            catch (NameConflictException)
            {
                Log.Info("Package already up-to-date");
                //Environment.Exit((int) ExitCode.PACKAGE_UP_TO_DATE);
            }
            catch (Exception e)
            {
                Log.Fatal($"Clone failed ({e.Message})", ExitCode.REPO_CLONE_FAILED);
            }

            var validator = new RepoValidator(CloneTo);
            validator.Validate();
        }

        public string Url { get; }
        public string CloneTo { get; }
    }
}
