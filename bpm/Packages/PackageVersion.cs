using bpm.Logging;
using bpm.Utilities;
using System.IO;

namespace bpm.Packages
{
    public class PackageVersion
    {
        public PackageVersion()
        {
            Major = 0;
            Minor = 0;
            Patch = 0;
        }

        public PackageVersion(int major, int minor, int patch)
        {
            Major = major;
            Minor = minor;
            Patch = patch;
        }

        public static PackageVersion Parse(string text)
        {
            int[] dots = new int[2] { 0, 0 };

            for (int i = 0; i < text.Length; i++)
            {
                if (text[i] == '.')
                {
                    if (dots[1] != 0)
                    {
                        Log.Fatal($"Could not parse version: {text} (Too many dots)", ExitCode.VERSION_PARSE_FAILED);
                        return new PackageVersion(0, 0, 0);
                    }

                    if (dots[0] == 0)
                        dots[0] = i;
                    else
                        dots[1] = i;
                }
            }

            string majorText = text[0..dots[0]];
            string minorText = text[(dots[0] + 1)..dots[1]];
            string patchText = text[(dots[1] + 1)..];

            bool majorParsed = int.TryParse(majorText, out var major);
            bool minorParsed = int.TryParse(minorText, out var minor);
            bool patchParsed = int.TryParse(patchText, out var patch);

            if (!majorParsed || !minorParsed || !patchParsed)
            {
                Log.Fatal($"Wrong version format ({text}). Usage: major.minor.patch", ExitCode.VERSION_PARSE_FAILED);
                return new PackageVersion(0, 0, 0);
            }

            return new PackageVersion(major, minor, patch);
        }

        public static int Compare(string s1, string s2)
        {
            var v1 = Parse(s1);
            var v2 = Parse(s1);

            if (v1.IsGreaterThan(v2))
                return 1;
            else if (v1.IsSameAs(v2))
                return 0;
            else
                return -1;
        }

        public bool IsGreaterThan(PackageVersion version)
        {
            if (Major > version.Major)
                return true;
            else if (Major < version.Major)
                return false;

            if (Minor > version.Minor)
                return true;
            else if (Minor < version.Minor)
                return false;

            if (Patch > version.Patch)
                return true;

            return false;
        }

        public override string ToString()
        {
            return $"{Major}.{Minor}.{Patch}";
        }

        public static PackageVersion FromPackageName(string package) => Package.FromGithubFile(Package.FromInstalledPackageName(package)).Version;

        public static PackageVersion FromInstalledPackageName(string package) => Package.FromInstalledPackageName(package).Version;

        public bool IsSameAs(PackageVersion version) => Major == version.Major && Minor == version.Minor && Patch == version.Patch;

        public int Major { get; set; }
        public int Minor { get; set; }
        public int Patch { get; set; }
    }
}