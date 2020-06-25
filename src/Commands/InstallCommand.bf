using Grill.API;
using Grill.CLI;
using System;
using System.IO;

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
					.Multiple()						
				)
				.Option(
					new CommandOption("local", "Install the package(s) only to this project")
					.Short("l")
				)
			~ delete _;

		public override CommandInfo Info => mInfo;

		public String[] Packages;
		public bool Local;

		public override void Execute()
		{
			for (var package in Packages)
			{
				CLI.Info("Installing {}", package);

				var url = scope String();
				API.GetPackageRepoUrl(package, url);

				var path = scope String();
				Path.InternalCombine(path, SpecialFolder.PackagesFolder, package);

				let result = Git.Clone(url, path);
				if (result case .Ok)
					CLI.Success("\rInstalled successfully");
				else
					CLI.Error("\rInstallation failed");
			}
		}
	}
}
