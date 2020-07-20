using System;
using System.IO;
using CowieCLI;
using System.Collections;
using JetFistGames.Toml;

namespace Grill
{
	public static class InstalledPackages
	{
		private static List<String> mPackages = new .() ~ DeleteContainerAndItems!(_);

		public static void LoadPackageList()
		{
			var dirs = Directory.EnumerateDirectories(GrillPath.PackagesDirectory);
			for (var dir in dirs)
			{
				var name = new String();
				dir.GetFileName(name);
				mPackages.Add(name);
			}
		}

		public static void GetPackage(Package dest, StringView name, PackageVersion version = null)
		{
			var serializedPackageName = scope String();
			if (version != null)
				serializedPackageName.AppendF("{}-{}", name, version);

			for (var package in mPackages)
			{
				if (version == null && package.Split('-').GetNext() == name || package == serializedPackageName)
				{
					SetPackage(package);
					return;
				}
			}		

			void SetPackage(String package)
			{
				var filePath = scope String();
				Path.InternalCombine(filePath, GrillPath.PackagesDirectory, package, "Package.toml");
				if (!File.Exists(filePath))
					return;

				let result = TomlSerializer.ReadFile(filePath, dest);
				if (result case .Err(let err))
					CowieCLI.Error("Could not read {} package file: {}", name, err);
			}
		}

		public static void ClearCache()
		{
			for (var dir in Directory.EnumerateDirectories(GrillPath.CacheDirectory))
			{
				var dirPath = scope String();
				dir.GetFilePath(dirPath);
				Directory.DelTree(dirPath);
			}

			for (var file in Directory.EnumerateFiles(GrillPath.CacheDirectory))
			{
				var filePath = scope String();
				file.GetFilePath(filePath);
				File.Delete(filePath);
			}
		}
	}
}
