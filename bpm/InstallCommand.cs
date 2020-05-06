using System;
using System.Diagnostics;
using System.IO;
using System.Linq;

namespace bpm
{
    public class InstallCommand : ICommand
    {
        public void Execute(string[] args)
        {
            Debug.Assert(args.Length == 1);

            Package package = null;
            try
            {
                var packages = PackageListFetcher.GetPackageList();
                package = packages.Single(p => string.Compare(p.Name, args[0], StringComparison.OrdinalIgnoreCase) == 0);
            }
            catch (InvalidOperationException)
            {
                Log.Fatal($"Could not find package: '{args[0]}'", ExitCode.PACKAGE_NOT_FOUND);
            }

            Console.WriteLine($"Installing: {package.Name} in {BpmUserFolder}\\packages\\{package.Name}");

            var cloner = new GithubRepoCloner(package.Url, $@"{BpmUserFolder}\packages\{package.Name}");
            cloner.Clone();

            Log.Success("Installed successfully");
        }

        public static string BpmUserFolder => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "bpm");
        public static string BpmGlobalFolder => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "bpm");
    }
}
