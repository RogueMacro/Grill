using System;
using System.Collections.Generic;
using ServiceStack;

namespace bpm
{
    public static class PackageListFetcher
    {
        public const string PackageListUrl = "https://raw.githubusercontent.com/RogueMacro/bpm/master/TestData.json";

        public static List<Package> GetPackageList()
        {
            Console.WriteLine("Fetching data...");
            var packageList = PackageListUrl.GetJsonFromUrl().FromJson<PackageList>();

            foreach (var package in packageList.Packages)
            {
                Console.WriteLine($"Fetched: {package.Name}-{package.Version}");
            }

            return packageList.Packages;
        }
    }
}
