using Grill.CLI;
using JetFistGames.Toml;
using System;
using System.IO;
using System.Collections;

namespace Grill.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class AddCommand : ICommand
	{
		public this() {}

		private CommandInfo mInfo =
			 new CommandInfo("install")
				.About("Adds package(s) to a workspace")
				.Option(
					new CommandOption("packages", "Package(s) to add")
					.Required()
				)
				.Option(
					new CommandOption("path", "Relative path to the workspace")
				)
			~ delete _;

		public override CommandInfo Info => mInfo;

		public List<String> Packages ~ DeleteContainerAndItems!(_);
		public String Path;

		public override void Execute()
		{
			// TODO: Change package directory name to <Package-x.x.x>

			// Read workspace file
			
			var workspaceFilePath = scope String();
			IO.Path.InternalCombine(workspaceFilePath, Path, "BeefSpace.toml");

			TomlTableNode workspace = null;
			ReadTomlFile!(workspaceFilePath, workspace);

			var projectsResult = workspace["Projects"].GetTable();
			if (projectsResult case .Err)
				projectsResult = workspace.AddChild<TomlTableNode>("Projects");

			var projects = (TomlTableNode) projectsResult.Get();

			// Check if workspace has a startup project

			bool hasStartupProject = true;

			if (workspace.FindChild("Workspace") == null || workspace["Workspace"]["StartupProject"] == null)
				hasStartupProject = false;

			// If it has a startup project, add packages as a dependency to that

			var projectFilePath = scope String();
			IO.Path.InternalCombine(projectFilePath, Path, "BeefProj.toml");

			TomlTableNode project = null;
			ReadTomlFile!(projectFilePath, project);

			var dependenciesResult = project["Dependencies"].GetTable();
			if (dependenciesResult case .Err)
				project.AddChild<TomlTableNode>("Dependencies");

			var dependencies = project["Dependencies"].GetTable().Get();

			for (var package in Packages)
			{
				var packagePath = scope String();
				IO.Path.InternalCombine(packagePath, SpecialFolder.PackagesFolder, package);
	
				if (!Directory.Exists(packagePath) && !CLI.Ask("Package is not installed, but was found in the package registry. Install?"))
				{
					let install = scope InstallCommand();
					install.Execute();
				}

				// Add to workspace

				if (projects.FindChild(package) != null)
				{
					CLI.Warning("{} is already added to this workspace", package);
					continue;
				}

				projects
					.AddChild<TomlTableNode>(package)
					.AddChild<TomlValueNode>("Path")
					.SetString(packagePath);

				if (!hasStartupProject)
					continue;

				// Add as dependency to Startup project

				if (dependencies.FindChild(package) == null)
					dependencies.AddChild<TomlValueNode>(package).SetString("*");
			}

			// Write to workspace file

			var serializedWorkspace = scope String();
			TomlSerializer.Write(workspace, serializedWorkspace);

			File.WriteAllText(workspaceFilePath, serializedWorkspace);

			// Write to project file

			var serializedProject = scope String();
			TomlSerializer.Write(project, serializedProject);

			File.WriteAllText(projectFilePath, serializedProject);

			delete workspace;
		}

		private mixin ReadTomlFile(StringView path, TomlTableNode doc)
		{
			if (!File.Exists(path))
			{
				var filename = scope String();
				IO.Path.GetFileName(path, filename);
				CLI.Error("Could not find TOML file: '{}'", filename);
				return;
			}

			var workspaceFile = scope String();
			let fileResult = File.ReadAllText(path, workspaceFile);
			if (fileResult case .Err(let err))
			{
				CLI.Error("Could not read '{}': {}", path, err);
				return;
			}

			let tomlResult = TomlSerializer.Read(workspaceFile);
			if (tomlResult case .Err(let err))
			{
				var filename = scope String();
				IO.Path.GetFileName(path, filename);
				CLI.Error("Error while parsing '{}': {}", filename, err);
				return;
			}

			doc = (.) tomlResult.Get();
		}
	}
}
