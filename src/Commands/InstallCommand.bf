using Grill.API;
using CowieCLI;
using System;
using System.IO;
using System.Collections;
using JetFistGames.Toml;
using Grill.Utility;
using CowieCLI;

namespace Grill.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class InstallCommand : ICommand
	{
		private CommandInfo mInfo =
			new CommandInfo("install")
				.About("Install Beef package(s)")
				.Option(
					new CommandOption("packages", "The package(s) to install")
					.Required()
				)
				.Option(
					new CommandOption("local", "Install the package(s) only to this project")
					.Short("l")
				)
			~ delete _;

		public override CommandInfo Info => mInfo;

		public List<String> Packages ~ DeleteContainerAndItems!(_);
		public bool Local;

		public override void Execute()
		{
			int dependenciesIndex = Packages.Count;
			int currentIndex = -1;


			var cachePath = scope String();
			if (Local)
				Path.InternalCombine(cachePath, "Packages", "Cache");
			else
				cachePath.Set(GrillPath.CacheDirectory);

			for (var package in Packages)
			{
				currentIndex++;

				CowieCLI.Print(.Cyan, CowieCLI.CurrentVerbosity == .Debug, "[Info] Installing {}", package);

				InstalledPackages.ClearCache();

				var url = scope String();
				if (package.IsUrl)
					url.Set(package);
				else
					API.GetPackageRepoUrl(package, url);
			
				if (Git.Clone(url, cachePath))
				{
					Console.Write("\r");
					CowieCLI.Success("Installed {}", package);
				}	
				else
				{
					if (CowieCLI.CurrentVerbosity == .Debug)
						Console.WriteLine();
					else
						Console.Write("\r");

					CowieCLI.Error("Could not install {}", package);
					continue;
				}	

				String packageFilePath = scope String();
				Path.InternalCombine(packageFilePath, cachePath, "Package.toml");
				if (!File.Exists(packageFilePath))
				{
					var librarySelector = scope SmartLibrarySelector(cachePath);
					var libraryName = scope String();
					librarySelector.GetLibraryName(libraryName);

					var dirPath = scope String();
					IO.Path.GetDirectoryPath(cachePath, dirPath);

					var newPath = scope String(dirPath);
					Path.InternalCombine(newPath, libraryName);
					Directory.Move(cachePath, newPath);
					continue;
				}

				var packageFile = scope Package();
				let tomlReadResult = TomlSerializer.ReadFile(packageFilePath, packageFile);

				if (tomlReadResult case .Err(let err))
				{
					CowieCLI.Error("{}", err);
					continue;
				}

				var dirPath = scope String();
				IO.Path.GetDirectoryPath(cachePath, dirPath);

				var newPath = scope String(dirPath);
				IO.Path.InternalCombine(newPath, scope String()..AppendF("{}-{}", packageFile.Name, packageFile.Version));

				if (Directory.Exists(newPath))
				{
					if (currentIndex < dependenciesIndex)
						CowieCLI.Warning("{} is already installed", package);

					continue;
				}

				Directory.Move(cachePath, newPath);

				for (var dep in packageFile.Dependencies.Values)
					Packages.Add(new String((String) dep));
			}
		}
	}
}
