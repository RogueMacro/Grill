using System;
using System.IO;
using JetFistGames.Toml;

namespace Grill.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class AddCommand : ICommand
	{
		public void Execute(String package, String path)
		{
			if (!path.Contains(":"))
			{
				var cwd = scope String();
				Directory.GetCurrentDirectory(cwd);
				var fullPath = scope:: String();
				Path.InternalCombine(fullPath, cwd, path);
				path.Set(fullPath);
			}

			Program.Debug("Adding package: {}", package);
			var packagePath = scope String();
			Path.InternalCombine(packagePath, SpecialFolder.PackagesFolder, package);
			if (Directory.Exists(packagePath))
			{
				Program.Debug("Project path: {}", path);
				var projectFilePath = scope String();
				Path.InternalCombine(projectFilePath, packagePath, "BeefSpace.toml");
				if (File.Exists(projectFilePath))
				{
					var projectFile = scope String();
					File.ReadAllText(projectFilePath, projectFile);
					let result = TomlSerializer.Read(projectFile);
					if (result case .Ok(let doc))
					{
						//Console.WriteLine(doc);

						delete doc;
					}
					else if (result case .Err(let err))
					{
						Program.Error("Failed to parse workspace file: {}", err);
					}
				}
				else
				{
					Program.Error("Could not find project file in '{}'", path);
				}
			}
			else
			{
				if (Program.Ask("Package is not installed, but was found in the package registry. Install?"))
				{
					let command = scope InstallCommand();
					let isInstalled = command.Execute(package, false);
					if (!isInstalled)
						return;

					Execute(package, path);
				}
			}
		}
	}
}
