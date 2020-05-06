using LibGit2Sharp;
using System;

namespace bpm
{
    public class Version
    {
        public Version(int major, int minor, int patch)
        {
            Major = major;
            Minor = minor;
            Patch = patch;
        }

        public static void Parse(string text, out Version version)
        {
            int[] dots = new int[2] { 0, 0 };

            for (int i = 0; i < text.Length; i++)
            {
                if (text[i] == '.')
                {
                    if (dots[1] != 0)
                        Log.Fatal($"Could not parse version: {text} (Too many dots)", ExitCode.VERSION_PARSE_FAILED);

                    if (dots[0] == 0)
                        dots[0] = i;
                    else
                        dots[1] = i;
                }
            }

            string majorText = text[0..dots[0]];
            string minorText = text[(dots[0]+1)..dots[1]];
            string patchText = text[(dots[1]+1)..];

            bool majorParsed = int.TryParse(majorText, out var major);
            bool minorParsed = int.TryParse(minorText, out var minor);
            bool patchParsed = int.TryParse(patchText, out var patch);

            if (!majorParsed || !minorParsed || !patchParsed)
            {
                Log.Fatal($"Wrong version format ({text}). Usage: major.minor.patch", ExitCode.VERSION_PARSE_FAILED);
            }

            version = new Version(major, minor, patch);
        }

        public override string ToString()
        {
            return $"{Major}.{Minor}.{Patch}";
        }

        public int Major { get; }
        public int Minor { get; }
        public int Patch { get; }
    }
}
