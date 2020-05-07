using bpm.Logging;
using bpm.Utilities;
using System;
using System.IO;
using System.Linq;

namespace bpm.Packages
{
    public class PackageValidator
    {
        public PackageValidator(string path)
        {
            Path = path;
        }

        public bool Validate()
        {
            var files = Directory.GetFiles(Path, "*.*", SearchOption.TopDirectoryOnly).Select(f => System.IO.Path.GetFileName(f));

            if (!files.Contains("BeefProj.toml"))
            {
                InvalidRepo("Missing BeefProj.toml");
                return false;
            }

            if (!files.Contains("Package.json"))
            {
                InvalidRepo("Missing Package.json");
                return false;
            }

            return true;
        }

        private void InvalidRepo(string info = null)
        {
            //BpmPath.DeleteDirectory(Path);
            Directory.Delete(Path, true);
            string text = "Package is not a valid beef project" + info != null ? $" ({info})" : "";
            Log.Fatal(text, ExitCode.INVALID_REPO);
        }

        public string Path { get; }
    }
}