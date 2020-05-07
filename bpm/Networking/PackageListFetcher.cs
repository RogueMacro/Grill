using bpm.Logging;
using bpm.Packages;
using bpm.Utilities;
using ServiceStack;

namespace bpm.Networking
{
    public static class PackageListFetcher
    {
        public static string PackageListUrl = BpmPath.GetPackageContentUrl(new Package("bpm", "RogueMacro", "0.0.0"), "Packages.json");

        public static PackageContainer GetPackages()
        {
            Log.Info("Fetching data");
            var packages = PackageListUrl.GetJsonFromUrl().FromJson<PackageContainer>();
            foreach (var package in packages.Keys)
                Log.Trace("Fetched: " + package);
            return packages;
        }
    }
}