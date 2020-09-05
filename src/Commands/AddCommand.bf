using CowieCLI;
using JetFistGames.Toml;
using System;
using System.IO;
using System.Collections;

namespace Grill.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class AddCommand : ICommand
	{
		private CommandInfo mInfo =
			new CommandInfo("install")
				.About("Adds package(s) to a workspace")
				.Option(
					new CommandOption("packages", "Package(s) to add")
					.List()
				)
				.Option(
					new CommandOption("path", "Relative path to the workspace")
					.Optional()
				)
			~ delete _;

		public override CommandInfo Info => mInfo;

		public List<String> Packages ~ DeleteContainerAndItems!(_);
		public String Path;

		public override int Execute()
		{
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
				IO.Path.InternalCombine(packagePath, GrillPath.PackagesDirectory, package);
	
				if (!Directory.Exists(packagePath) && !CowieCLI.Ask("Package is not installed, but was found in the package registry. Install?"))
				{
					let install = scope InstallCommand();
					install.Execute();
				}

				// Add to workspace

				if (projects.FindChild(package) != null)
				{
					CowieCLI.Warning("{} is already added to this workspace", package);
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
			return 0;
		}

		private mixin ReadTomlFile(StringView path, TomlTableNode doc)
		{
			if (!File.Exists(path))
			{
				var filename = scope String();
				IO.Path.GetFileName(path, filename);
				CowieCLI.Error("Could not find TOML file: '{}'", filename);
				return 1;
			}

			var workspaceFile = scope String();
			let fileResult = File.ReadAllText(path, workspaceFile);
			if (fileResult case .Err(let err))
			{
				CowieCLI.Error("Could not read '{}': {}", path, err);
				return 2;
			}

			let tomlResult = TomlSerializer.Read(workspaceFile);
			if (tomlResult case .Err(let err))
			{
				var filename = scope String();
				IO.Path.GetFileName(path, filename);
				CowieCLI.Error("Error while parsing '{}': {}", filename, err);
				return 3;
			}

			doc = (.) tomlResult.Get();
		}
	}
}
