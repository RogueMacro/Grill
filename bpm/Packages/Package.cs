using bpm.Logging;
using bpm.Utilities;
using ServiceStack;
using System;
using System.IO;
using System.Net;
using System.Runtime.Serialization;

namespace bpm.Packages
{
    [DataContract]
    public class Package
    {
        public Package(string name, string author, string version, string description = "")
        {
            Name = name;
            Description = description;
            Author = author;
            VersionString = version;
            mVersion = PackageVersion.Parse(VersionString);
        }

        public static Package FromGithubFile(string url)
        {
            try
            {
                return url.GetJsonFromUrl().FromJson<Package>();
            }
            catch (WebException e)
            {
                Log.Fatal(e.Message, ExitCode.NET_ERROR);
            }

            return null;
        }

        public static Package FromFile(string path)
        {
            string file = File.ReadAllText(path);
            return file.FromJson<Package>();
        }

        [DataMember] public string Name { get; set; }
        [DataMember] public string Description { get; set; }
        [DataMember] public string Author { get; set; }

        public static Package FromInstalledPackageName(string packageName)
        {
            var packagePath = BpmPath.GetPackagePath(packageName);
            return FromFile(Path.Combine(packagePath, "Package.json"));
        }

        public static Package FromGithubFile(Package package)
        {
            var githubFile = BpmPath.GetPackageFileUrl(package);
            return FromGithubFile(githubFile);
        }

        [DataMember(Name = "Version")] public string VersionString { get; set; }

        private PackageVersion mVersion { get; }
        public PackageVersion Version
        {
            get
            {
                if (mVersion == null)
                    return PackageVersion.Parse(VersionString);
                return mVersion;
            }
        }

        public string RepoUrl => BpmPath.GetPackageRepoUrl(this);
        public string ContentUrl => BpmPath.GetPackageContentUrl(this);
        public string GithubFile => BpmPath.GetPackageFileUrl(this);
        public string LocalFile => BpmPath.GetPackagePath(Name);
    }
}
