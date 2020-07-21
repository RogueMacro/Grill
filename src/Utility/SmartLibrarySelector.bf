using System;
using System.IO;
using JetFistGames.Toml;
using System.Collections;
using CowieCLI;

namespace Grill.Utility
{
	public class SmartLibrarySelector
	{
		public String LibraryPath = new .() ~ delete _;

		public this(StringView path)
		{
			LibraryPath.Set(path);
		}

		public void GetLibraryName(String buffer)
		{
			var rootFilePath = scope String();
			Path.InternalCombine(rootFilePath, LibraryPath, "BeefProj.toml");
			if (File.Exists(rootFilePath))
			{
				var project = scope Project();
				var result = TomlSerializer.ReadFile(rootFilePath, project);

				if (result case .Err(let err))
				{
					CowieCLI.Error("Could not parse project file {}: {}", rootFilePath, err);
					return;
				}

				buffer.Append((String) project.Name);
				return;
			}

			var libraryProjects = scope List<Project>();

			for (var dir in Directory.EnumerateDirectories(LibraryPath))
			{
				var dirPath = scope String();
				dir.GetFilePath(dirPath);

				var filePath = scope String();
				Path.InternalCombine(filePath, dirPath, "BeefProj.toml");
				if (!File.Exists(filePath))
					continue;

				var project = scope:: Project();
				var result = TomlSerializer.ReadFile(filePath, project);

				if (result case .Err(let err))
				{
					CowieCLI.Error("Could not parse project file {}: {}", filePath, err);
					continue;
				}

				if (!project.Project.ContainsKey("TargetType"))
					libraryProjects.Add(project);
			}

			// Search projects for the project at the top of the dependency tree (only includes static libraries)
			ProjectLoop: for (var projectToCheck in libraryProjects)
			{
				// Check if any other project is dependent on this project
				for (var project in libraryProjects)
				{
					if (project == projectToCheck)
						continue;

					// A project is dependent on this project
					if (project.Dependencies.ContainsKey(projectToCheck.Name))
						continue ProjectLoop;
				}

				// No projects were dependent on this project a.k.a. it is at the top of the dependency tree
				buffer.Append(projectToCheck.Name);
				return;
			}	
		}
	}
}
