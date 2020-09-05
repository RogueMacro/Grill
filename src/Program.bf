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
			var cli = scope CowieCLI("Grill", "The Beeflang package manager");

			Git.Init();

			Config.Load();
			InstalledPackages.LoadPackageList();

			cli.RegisterCommand<InitCommand>("init");
			cli.RegisterCommand<InstallCommand>("install");
			cli.RegisterCommand<AddCommand>("add");

			cli.Run(args);
		}
	}
}
