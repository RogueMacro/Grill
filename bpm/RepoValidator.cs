using ServiceStack;
using ServiceStack.Text;
using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography.X509Certificates;

namespace bpm
{
    public class RepoValidator
    {
        public RepoValidator(string path)
        {
            Path = path;
        }

        public Version Validate()
        {
            var files = Directory.GetFiles(Path, "*.*", SearchOption.TopDirectoryOnly).Select(f => System.IO.Path.GetFileName(f));

            if (!files.Contains("BeefProj.toml"))
                Log.Warning("Missing BeefProj.toml");

            if (!files.Any(f => f.EndsWith(".pkg")))
                Log.Warning("Missing .pkg file");

            Version.Parse("0.0.0", out var version); // TODO
            return version;
        }

        private void DeleteAndExit(string info = null)
        {
            DeleteDirectory(Path);
            string text = "Package is not a valid beef project" + info != null ? $" ({info})" : "";
            Log.Fatal(text, ExitCode.INVALID_REPO);
        }

        public void DeleteDirectory(string targetDir)
        {
            File.SetAttributes(targetDir, FileAttributes.Normal);

            string[] files = Directory.GetFiles(targetDir);
            string[] dirs = Directory.GetDirectories(targetDir);

            foreach (string file in files)
            {
                File.SetAttributes(file, FileAttributes.Normal);
                File.Delete(file);
            }

            foreach (string dir in dirs)
                DeleteDirectory(dir);

            Directory.Delete(targetDir, false);
        }

        public string Path { get; }
    }
}
