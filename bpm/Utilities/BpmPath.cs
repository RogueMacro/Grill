using bpm.Networking;
using bpm.Packages;
using System;
using System.IO;

namespace bpm.Utilities
{
    public static class BpmPath
    {
        public static string LogFolder
            => ForceExist(Path.Combine(UserFolder, "logs"));

        public static string UserFolder
            => ForceExist(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "bpm"));

        public static string GlobalFolder
            => ForceExist(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "bpm"));

        public static string GetPackageContentUrl(Package package)
            => Url.Combine(package.RepoUrl, "raw", "master");

        public static string GetPackageContentUrl(Package package, string file)
            => Url.Combine(GetPackageContentUrl(package), file);

        public static string GetPackageFileUrl(Package package)
            => Url.Combine(GetPackageContentUrl(package), "Package.json");

        public static string ForceExist(string path)
        {
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            return path;
        }

        public static string GetPackagePath(string package, bool isGlobal = false)
        {
            if (isGlobal)
            {
                if (GetGlobalPackagePath(package, out var path))
                    return path;
            }
            else
            {
                if (GetUserPackagePath(package, out var path))
                    return path;

                if (GetGlobalPackagePath(package, out path))
                    return path;
            }

            return null;
        }

        public static bool GetUserPackagePath(string package, out string path)
        {
            string packageDir = Path.Combine(UserFolder, "packages", package);
            if (Directory.Exists(packageDir))
            {
                path = packageDir;
                return true;
            }

            path = "";
            return false;
        }

        public static bool GetGlobalPackagePath(string package, out string path)
        {
            string packageDir = Path.Combine(GlobalFolder, "packages", package);
            if (Directory.Exists(packageDir))
            {
                path = packageDir;
                return true;
            }

            path = "";
            return false;
        }

        public static void DeleteDirectory(string targetDir)
        {
            File.SetAttributes(targetDir, FileAttributes.Normal);

            var files = Directory.GetFiles(targetDir);
            var dirs = Directory.GetDirectories(targetDir);

            foreach (string file in files)
            {
                File.SetAttributes(file, FileAttributes.Normal);
                File.Delete(file);
            }

            foreach (string dir in dirs)
                DeleteDirectory(dir);

            Directory.Delete(targetDir, false);
        }
    }
}
