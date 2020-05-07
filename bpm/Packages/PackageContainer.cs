using bpm.Networking;
using ServiceStack;
using System;
using System.Collections.Generic;

namespace bpm.Packages
{
    public class PackageContainer : Dictionary<string, string>
    {
        public PackageContainer() : base(StringComparer.OrdinalIgnoreCase)
        { }

        public Package GetPackage(string name)
        {
            if (ContainsKey(name))
            {
                var repoUrl = this[name];
                var packageFileUrl = Url.Combine(repoUrl, "raw", "master", "Package.json");
                var package = packageFileUrl.GetJsonFromUrl().FromJson<Package>();
                return package;
            }

            return null;
        }
    }
}