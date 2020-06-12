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
			if (path.Length >= 2 && path[1] != ':')
			{
				var cwd = scope String();
				Directory.GetCurrentDirectory(cwd);
				var fullPath = scope:: String();
				Path.InternalCombine(fullPath, cwd, path);
				path.Set(fullPath);
			}

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
						var projectsResult = doc["Projects"].GetTable();
						if (projectsResult case .Ok(let projects))
 						{
							if (projects.FindChild(package) == null)
							{
								Program.Info("Adding package: {}", package);

								projects
									.AddChild<TomlTableNode>(package)
									.AddChild<TomlValueNode>("Path")
									.SetString(path);

								var serialized = scope String();
								TomlSerializer.Write((TomlTableNode) doc, serialized);
								Console.WriteLine("Serialized: {}", serialized);

								Program.Success("Package added");
							}
							else
							{
								Program.Error("Package already added to this project");
							}
						}
						else
						{
							Program.Error("Failed to get projects from workspace file");
						}

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
