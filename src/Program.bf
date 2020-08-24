using CowieCLI;
using Grill.Commands;
using System;
using System.Collections;
using System.Reflection;
using System.Net;
using System.IO;
using JetFistGames.Toml;

namespace Grill
{
	public static class Program
	{
		static void Main(String[] args)
		{
			CowieCLI.Init(
				"""
				Beef Package Manager
	
				USAGE:
				    grill <command> [options]
	
				OPTIONS:
				    -V, --version   Show the current version of Grill
				    -v, --verbose   Use verbose output
				        --list      List all commands
				    -q, --quiet     Disable output
				"""
			);

			Git.Init();

			Config.Load();
			InstalledPackages.LoadPackageList();

			CowieCLI.RegisterCommand<InitCommand>("init");
			CowieCLI.RegisterCommand<InstallCommand>("install");
			CowieCLI.RegisterCommand<AddCommand>("add");

			CowieCLI.Run(args);
		}
	}
}
