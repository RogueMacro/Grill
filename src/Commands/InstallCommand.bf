using Grill.API;
using System;
using System.IO;

namespace Grill.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class InstallCommand : ICommand
	{
		public bool Execute(String package, bool global)
		{
			if (Program.IsDebug)
				Program.Print(.Cyan, "Installing {}, global={}", package, global);
			else
				Program.Print(.Cyan, "Installing {}", package);

			var url = scope String();
			API.GetPackageRepoUrl(package, url);

			var path = scope String();
			Path.InternalCombine(path, SpecialFolder.PackagesFolder, package);

			let result = Git.Clone(url, path);
			if (result case .Ok)
				Program.Success("Installed successfully");
			else
				Program.Error("Installation failed");

			return result case .Ok;
		}
	}
}
