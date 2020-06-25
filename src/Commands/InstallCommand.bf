using Grill.API;
using Grill.CLI;
using System;
using System.IO;
using System.Collections;

namespace Grill.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class InstallCommand : ICommand
	{
		public this() {}

		private static CommandInfo mInfo =
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
			for (var package in Packages)
			{
				var path = scope String();
				Path.InternalCombine(path, SpecialFolder.PackagesFolder, package);

				if (Directory.Exists(path))
				{
					CLI.Warning("{} is already installed", package);
					continue;
				}

				CLI.Info("Installing {}", package);

				var url = scope String();
				API.GetPackageRepoUrl(package, url);

				let result = Git.Clone(url, path);
				if (result case .Ok)
					CLI.Success("\rInstalled successfully");
				else
					CLI.Error("\rInstallation failed");
			}
		}
	}
}
