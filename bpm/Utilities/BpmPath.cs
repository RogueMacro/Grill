using bpm.Networking;
using bpm.Packages;
using System;
using System.IO;

namespace bpm.Utilities
{
    public static class BpmPath
    {
        public static string LogFolder
            => Path.Combine(UserFolder, "logs");

        public static string UserFolder
            => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "bpm");

        public static string GlobalFolder
            => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "bpm");

        public static string GetPackageRepoUrl(Package package)
            => Url.Combine("https://github.com/", package.Author, package.Name);

        public static string GetPackageContentUrl(Package package)
            => Url.Combine("https://raw.githubusercontent.com/", package.Author, package.Name, "master");

        public static string GetPackageContentUrl(Package package, string file)
            => Url.Combine(GetPackageContentUrl(package), file);

        public static string GetPackageFileUrl(Package package)
            => Url.Combine(GetPackageContentUrl(package), "Package.json");

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

        public static bool HasReadAccess(string path)
        {
            try
            {
                File.ReadAllText(path);
                return true;
            }
            catch (UnauthorizedAccessException)
            {
                return false;
            }
        }

        public static bool HasWriteAccess(string path)
        {
            try
            {
                path = new DirectoryInfo(path).FullName;
                File.Create(Path.Combine(path, "tempfile_blfasdfdasgdfs.txt")).Close();
                File.Delete(Path.Combine(path, "tempfile_blfasdfdasgdfs.txt"));
                return true;
            }
            catch (UnauthorizedAccessException)
            {
                return false;
            }
        }
    }
}
