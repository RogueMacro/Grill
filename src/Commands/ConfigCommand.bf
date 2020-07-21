using System;
using CowieCLI;

namespace Grill.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class ConfigCommand : ICommand
	{
		private CommandInfo mInfo =
			new CommandInfo("config")
				.About("Edit grill config")
				.Option(
					new CommandOption("override", "What package to override")
					.Short("l")
				)
				.Option(
					new CommandOption("default-namespace", "Auto-rename the base namespace for this package")
					.Short("n")
					.Requires("override")
				)
			~ delete _;

		public override CommandInfo Info => mInfo;

		public String Override ~ delete _;

		public override void Execute()
		{

		}
	}
}
