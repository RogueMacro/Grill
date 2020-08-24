using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using CowieCLI;

namespace Grill.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class InitCommand : ICommand
	{
		private CommandInfo mInfo =
			new CommandInfo("init")
				.About("Initialize a new Grill package.")
				.Option(
					new CommandOption("name", "The package name")
				)
				.Option(
					new CommandOption("location", "The location where to install the package")
				)
			 ~ delete _;
		public override CommandInfo Info => mInfo;

		public String Name = default(String) ~ delete (_);
		public String Location = default(String) ~ delete (_);

		public override void Execute()
		{
			var beefBuildExec = scope String("BeefBuild");
			var beefBuildArgs = scope String("-new -generate");

			if (Location.IsEmpty || Location.Equals("."))
			{
				Directory.GetCurrentDirectory(Location);
			}

			if (!Name.IsEmpty)
			{
				Path.InternalCombine(Location, Name);
			}
			else
			{
				Path.GetFileName(Location, Name);
			}

			if (!Directory.Exists(Location))
			{
				if (Directory.CreateDirectory(Location) case .Err(let err))
				{
					CowieCLI.Error("Couldn't create project's directory at {}", Location);
					return;
				}
			}

			var beefBuildProcessInfo = scope ProcessStartInfo();
			beefBuildProcessInfo.SetFileName(beefBuildExec);
			beefBuildProcessInfo.SetArguments(beefBuildArgs);
			beefBuildProcessInfo.SetWorkingDirectory(Location);

			var beefBuildProcess = scope SpawnedProcess();
			beefBuildProcess.Start(beefBuildProcessInfo);

			if (beefBuildProcess.WaitFor() && (beefBuildProcess.ExitCode == 0))
			{
				CowieCLI.Success("Project {} successfully created!", Name);
			}

			beefBuildProcess.Close();
		}
	}
}
